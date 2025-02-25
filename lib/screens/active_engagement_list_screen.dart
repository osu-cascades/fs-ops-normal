import 'package:flutter/material.dart';
import 'estimate_list_screen.dart';
import '../event_handlers/popup_menu_button_handler.dart';
import '../event_handlers/floating_action_button_handler.dart';
import '../models/engagement.dart';
import '../persistence/database_manager.dart';
import '../persistence/engagement_dao.dart';
import '../persistence/estimate_dao.dart';
import '../utils/date_time_formatter.dart';
import '../widgets/new_engagement_dialog.dart';

class ActiveEngagementListScreen extends StatefulWidget {
  const ActiveEngagementListScreen(
      {Key? key,
      required this.popupMenuButtonHandler,
      required this.floatingActionButtonHandler})
      : super(key: key);

  final FloatingActionButtonHandler floatingActionButtonHandler;
  final PopupMenuButtonHandler popupMenuButtonHandler;

  static const routeName = '/';

  @override
  ActiveEngagementListScreenState createState() =>
      ActiveEngagementListScreenState();
}

class ActiveEngagementListScreenState
    extends State<ActiveEngagementListScreen> {
  List<Engagement>? engagements;
  get _noEngagements => engagements == null || engagements!.isEmpty;

  @override
  void initState() {
    super.initState();
    loadEngagements();
    widget.floatingActionButtonHandler.onPressed = () {
      showDialog(context: context, builder: (context) => NewEngagementDialog())
          .then((value) {
        if (value) {
          setState(() {
            loadEngagements();
          });
        }
      });
    };
    widget.popupMenuButtonHandler.onSelected = (String order) {
      setState(() {
        if (order == 'oldest') {
          setState(() {
            engagements!.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          });
        } else if (order == 'newest') {
          setState(() {
            engagements!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          });
        }
      });
    };
  }

  void loadEngagements({bool notFirstOpen = true}) async {
    engagements = await EngagementDAO.activeEngagements(
        databaseManager: DatabaseManager.getInstance());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (engagements == null) {
      return const Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      );
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _bodyChildren());
    }
  }

  Widget _emptyListPrompt() => const Text("No engagements created yet.");
  //Widget _swipePrompt() => const Text("Swipe left to see archived engagements.");

  List<Widget> _bodyChildren() {
    if (_noEngagements) {
      return [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_emptyListPrompt()],
          ),
        ),
        //_swipePrompt()
      ];
    } else {
      return [
        const Text('Engagements'),
        Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: engagements!.length,
              itemBuilder: (context, index) =>
                  _dismissible(engagements![index])),
        ),
        //_swipePrompt()
      ];
    }
  }

  Widget _dismissible(Engagement engagement) {
    return Dismissible(
        key: Key(engagement.id.toString()),
        background: _archiveBackground(),
        secondaryBackground: _deleteBackground(),
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.25,
          DismissDirection.endToStart: 0.25
        },
        confirmDismiss: (DismissDirection direction) async {
          return await _confirmDismiss(direction);
        },
        onDismissed: (direction) {
          _archiveOrDeleteEngagement(direction, engagement);
        },
        child: _listTile(engagement));
  }

  Widget _listTile(Engagement engagement) {
    return ListTile(
      title: Text(engagement.name, style: const TextStyle(fontSize: 22)),
      subtitle: Text(
          'Created: ${DateTimeFormatter.format(engagement.createdAt)}',
          style: const TextStyle(fontSize: 18)),
      onTap: () {
        EstimateDAO.estimates(
                databaseManager: DatabaseManager.getInstance(),
                engagement: engagement)
            .then((estimates) => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EstimateListScreen(
                      engagement: engagement,
                      estimates: estimates,
                      isActive: true,
                    );
                  }))
                });
      },
    );
  }

  Widget _archiveBackground() {
    return Stack(children: [
      Container(
        color: Colors.green,
        child: Align(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(_archivingIconData(), color: Colors.white),
              Text(_archivingIconText(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(width: 20)
            ],
          ),
        ),
      ),
    ]);
  }

  IconData _archivingIconData() {
    return Icons.archive_rounded;
  }

  String _archivingIconText() {
    return "Archive";
  }

  Widget _deleteBackground() {
    return Stack(
      children: [
        Container(
          color: Colors.red,
          child: Align(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.delete_forever_outlined, color: Colors.white),
                Text("Delete",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                SizedBox(width: 20)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _confirmDismiss(direction) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          if (direction == DismissDirection.endToStart) {
            return _alertDialog("Delete");
          } else {
            return _alertDialog("Archive");
          }
        });
  }

  void _archiveOrDeleteEngagement(direction, Engagement engagement) {
    if (direction == DismissDirection.endToStart) {
      EngagementDAO.delete(
          databaseManager: DatabaseManager.getInstance(),
          engagement: engagement);
    } else {
      EngagementDAO.deactivate(
          databaseManager: DatabaseManager.getInstance(),
          engagement: engagement);
    }
    loadEngagements();
  }

  Widget _alertDialog(deleteOrArchive) {
    return AlertDialog(
      title: deleteOrArchive == "Archive"
          ? const Text("Archive Engagement")
          : const Text("Delete Engagement"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Yes"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("No"),
        )
      ],
    );
  }
}

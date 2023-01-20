import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/estimate.dart';

class EstimateScreen extends StatefulWidget {
  static const routeName = 'estimateScreen';

  const EstimateScreen({Key? key}) : super(key: key);

  @override
  State<EstimateScreen> createState() {
    return _EstimateScreenState();
  }
}

class EstimateScreenArgs {
  final bool isNew;
  final Estimate estimate;

  EstimateScreenArgs(this.isNew, this.estimate);
}

class _EstimateScreenState extends State<EstimateScreen> {
  @override
  Widget build(BuildContext context) {
    final EstimateScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as EstimateScreenArgs;
    final Estimate estimate = args.estimate;
    final bool isNew = args.isNew;

    return WillPopScope(
        onWillPop: () async {
          if (isNew) {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: const Text("Estimate Screen"),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                    height: 10,
                    width: double
                        .infinity), //invisible container to make column max-width
                const Text(
                  "Acres Order",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                ),
                SelectableText(
                  estimate.flatFireOrderText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                Container(child: floatingActionButtonAcres(estimate, context)),
                const SizedBox(
                    height: 50,
                    width: double
                        .infinity), //invisible container to make column max-width
                const Text(
                  "Structures Order",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                ),
                SelectableText(
                  estimate.structureFireOrderText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                Container(
                    child: floatingActionButtonStructures(estimate, context)),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: homeButton(),
        ));
  }

  Widget? homeButton() {
    return FloatingActionButton(
        onPressed: () {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          setState(() {});
        },
        heroTag: 'homeButton',
        child: const Icon(Icons.home));
  }

  Widget floatingActionButtonAcres(estimate, context) {
    return FloatingActionButton(
        heroTag: "CopyAcres",
        child: const Icon(Icons.copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: estimate.flatFireOrderText()))
              .then((value) =>
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Copied to Clipboard"),
                  )));
        });
  }

  Widget floatingActionButtonStructures(estimate, context) {
    return FloatingActionButton(
        heroTag: "CopyStructures",
        child: const Icon(Icons.copy),
        onPressed: () {
          Clipboard.setData(
                  ClipboardData(text: estimate.structureFireOrderText()))
              .then((value) =>
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Copied to Clipboard"),
                  )));
        });
  }

  Widget floatAccButton(estimate, context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: estimate.toCopyString())).then(
            (value) =>
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Copied to Clipboard"),
                )));
      },
      icon: const Icon(Icons.copy),
      label: const Text("Copy"),
    );
  }
}

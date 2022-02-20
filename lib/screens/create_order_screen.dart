import 'package:flutter/material.dart';
import 'modify_estimate_screen.dart';
import '../models/estimate.dart';
import '../utils/time_format.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  static const routeName = 'createOrderScreen';
  static const title = "CreateOrderScreen";

  final bool _acreageInputIsValid = true;
  final bool _structureInputIsValid = true;

  final _acreage = '5';
  final _structures = '5';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Order Screen'),
        ),
        body: ListView(
          children: <Widget>[
            Padding(padding: const EdgeInsets.all(10)),
            TextField(
                controller: null,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Enter acreage',
                    errorText: _acreageInputIsValid ? null : 'error',
                    border: const OutlineInputBorder())),
            Padding(padding: const EdgeInsets.all(10)),
            TextField(
                controller: null,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Enter Structures',
                    errorText: _structureInputIsValid ? null : 'error',
                    border: const OutlineInputBorder())),
            OutlinedButton(
                onPressed: () {
                  var estimate = new Estimate(
                      acres: int.parse(_acreage),
                      structures: int.parse(_structures),
                      timeStamp: TimeFormat.currentTime);
                  estimate.initialLineCalculation();
                  _acreage.isNotEmpty
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ModifyEstimateScreen(
                                    estimate: estimate,
                                    // engagement: engagement,
                                  )),
                        )
                      : ArgumentError.notNull('Value Can\'t Be Empty');
                },
                child: Text("Create Order"))
          ],
        ));
  }
}

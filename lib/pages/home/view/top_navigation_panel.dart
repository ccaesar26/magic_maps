import 'package:flutter/material.dart';
import 'package:magic_maps/pages/home/view/instruction_model.dart';

class NavigationInstructionPanel extends StatelessWidget {
  final InstructionModel instruction;

  const NavigationInstructionPanel({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      height: MediaQuery.of(context).size.height * 0.2,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(15)),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          width: 100,
          child: instruction.nextTurnImageData != null
              ? Image.memory(
                  instruction.nextTurnImageData!,
                  gaplessPlayback: true,
                )
              : Container(),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                instruction.nextTurnDistance,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                instruction.nextStreetName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      ]),
    );
  }
}

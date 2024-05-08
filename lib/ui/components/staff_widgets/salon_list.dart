import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/string/strings.dart';
import 'package:untitled2/view_model/staff_home/staff_home_view_model.dart';
import '../../../model/salon_model.dart';

staffDisplaySalon(WidgetRef ref, StaffHomeViewModel staffHomeViewModel, String name) {
  return FutureBuilder(
      future: staffHomeViewModel.displaySalonByCity(ref, name),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var salons = snapshot.data as List<SalonModel>;
          if (salons.isEmpty) {
            return const Center(
              child: Text(cannotLoadSalonListText),
            );
          } else {
            return ListView.builder(
                itemCount: salons.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                    staffHomeViewModel.onSelectedSalon(ref, context, salons[index]),
                    child: Card(
                      child: ListTile(
                        shape: staffHomeViewModel.isSalonSelected(ref, context, salons[index])
                            ? RoundedRectangleBorder(
                            side:
                            const BorderSide(color: Colors.green, width: 4),
                            borderRadius: BorderRadius.circular(5))
                            : null,
                        leading: const Icon(
                          Icons.home_outlined,
                          color: Colors.black,
                        ),
                        trailing: staffHomeViewModel.isSalonSelected(ref, context, salons[index])
                            ? const Icon(Icons.check)
                            : null,
                        title: Text(
                          salons[index].name,
                          style: GoogleFonts.robotoMono(),
                        ),
                        subtitle: Text(
                          salons[index].address,
                          style: GoogleFonts.robotoMono(
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  );
                });
          }
        }
      });
}
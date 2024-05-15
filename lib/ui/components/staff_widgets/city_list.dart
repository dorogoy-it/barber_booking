import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled2/string/strings.dart';
import 'package:untitled2/view_model/staff_home/staff_home_view_model.dart';
import '../../../model/city_model.dart';

staffDisplayCity(WidgetRef ref, StaffHomeViewModel staffHomeViewModel) {
  return FutureBuilder(
      future: staffHomeViewModel.displayCities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var cities = snapshot.data as List<CityModel>;
          if (cities.isEmpty) {
            return const Center(
              child: Text(cannotLoadCityText),
            );
          } else {
            return GridView.builder(
                itemCount: cities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        staffHomeViewModel.onSelectedCity(ref, context, cities[index]),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        shape: staffHomeViewModel.isCitySelected(ref, context, cities[index])
                            ? RoundedRectangleBorder(
                            side:
                            const BorderSide(color: Colors.green, width: 4),
                            borderRadius: BorderRadius.circular(5))
                            : null,
                        child: Center(
                          child: Text(cities[index].name),
                        ),
                      ),
                    ),
                  );
                });
          }
        }
      });
}
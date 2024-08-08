import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/string/strings.dart';
import 'package:untitled2/view_model/booking/booking_view_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../../model/salon_model.dart';

displaySalon(WidgetRef ref, BookingViewModel bookingViewModel, String cityName) {
  return FutureBuilder(
    future: bookingViewModel.displaySalonByCity(ref, cityName),
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
            key: const PageStorageKey('keep'),
            itemCount: salons.length,
            itemBuilder: (context, index) {
              return SalonMapItem(
                salon: salons[index],
                bookingViewModel: bookingViewModel,
                ref: ref,
              );
            },
          );
        }
      }
    },
  );
}

class SalonMapItem extends StatefulWidget {
  final SalonModel salon;
  final BookingViewModel bookingViewModel;
  final WidgetRef ref;

  const SalonMapItem({
    super.key,
    required this.salon,
    required this.bookingViewModel,
    required this.ref,
  });

  @override
  SalonMapItemState createState() => SalonMapItemState();
}

class SalonMapItemState extends State<SalonMapItem> {
  YandexMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.bookingViewModel.changeSalon(widget.ref, context);
        widget.bookingViewModel.onSelectedSalon(widget.ref, context, widget.salon);
      },
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.home_outlined,
                color: Colors.black,
              ),
              trailing: widget.bookingViewModel.isSalonSelected(widget.ref, context, widget.salon)
                  ? const Icon(Icons.check)
                  : null,
              title: Text(
                widget.salon.name,
                style: GoogleFonts.robotoMono(),
              ),
              subtitle: Text(
                widget.salon.address,
                style: GoogleFonts.robotoMono(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  YandexMap(
                    mapObjects: [
                      PlacemarkMapObject(
                        mapId: MapObjectId('salon_${widget.salon.docId}'),
                        point: Point(
                          latitude: widget.salon.latitude,
                          longitude: widget.salon.longitude,
                        ),
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage('assets/images/metka.png'),
                          ),
                        ),
                      ),
                    ],
                    onMapCreated: (YandexMapController controller) {
                      setState(() {
                        _mapController = controller;
                      });
                      controller.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: Point(
                              latitude: widget.salon.latitude,
                              longitude: widget.salon.longitude,
                            ),
                            zoom: 17.0,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          mini: true,
                          child: const Icon(Icons.add),
                          onPressed: () {
                            if (_mapController != null) {
                              _mapController!.moveCamera(
                                CameraUpdate.zoomIn(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          mini: true,
                          child: const Icon(Icons.remove),
                          onPressed: () {
                            if (_mapController != null) {
                              _mapController!.moveCamera(
                                CameraUpdate.zoomOut(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
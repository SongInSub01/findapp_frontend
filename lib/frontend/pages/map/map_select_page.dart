import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/pages/map/map_kakao_bridge.dart';

class MapSelectPage extends StatefulWidget {
  const MapSelectPage({super.key});

  @override
  State<MapSelectPage> createState() =>
      _MapSelectPageState();
}

class _MapSelectPageState
    extends State<MapSelectPage> {
  late KakaoMapController
  _mapController;

  final TextEditingController
  _searchController =
      TextEditingController();

  final Dio _dio = Dio();

  static const String
  _kakaoRestApiKey =
      '701601b0279c7917740debb1691deb26';

  List<dynamic> _places = [];

  LatLng? _selectedLatLng;

  String _selectedAddress =
      '';

  bool _isSearching = false;

  Future<void> _searchPlace(
    String keyword,
  ) async {
    if (keyword.trim().isEmpty) {
      return;
    }

    try {
      setState(() {
        _isSearching = true;
      });

      final response =
          await _dio.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',

        queryParameters: {
          'query': keyword,
        },

        options: Options(
          headers: {
            'Authorization':
                'KakaoAK $_kakaoRestApiKey',
          },
        ),
      );

      setState(() {
        _places =
            response
                .data['documents'];
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectPlace(
    dynamic place,
  ) {
    final lat = double.parse(
      place['y'],
    );

    final lng = double.parse(
      place['x'],
    );

    final latLng = LatLng(
      lat,
      lng,
    );

    setState(() {
      _selectedLatLng =
          latLng;

      _selectedAddress =
          place['place_name'];
    });

    _mapController.setCenter(
      latLng,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.white,

        title: const Text(
          '분실 위치 선택',

          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        iconTheme:
            const IconThemeData(
              color: Colors.black,
            ),
      ),

      body: Column(
        children: [
          /// 검색창
          Padding(
            padding:
                const EdgeInsets.all(
                  16,
                ),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        _searchController,

                    decoration:
                        InputDecoration(
                          hintText:
                              '장소 검색',

                          filled: true,

                          fillColor:
                              const Color(
                                0xFFF4F7FB,
                              ),

                          border:
                              OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                      16,
                                    ),

                                borderSide:
                                    BorderSide.none,
                              ),

                          prefixIcon:
                              const Icon(
                                Icons.search,
                              ),
                        ),

                    onSubmitted:
                        _searchPlace,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                SizedBox(
                  height: 54,

                  child: FilledButton(
                    onPressed: () {
                      _searchPlace(
                        _searchController
                            .text,
                      );
                    },

                    child: const Text(
                      '검색',
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 검색 결과
          if (_isSearching)
            const Padding(
              padding:
                  EdgeInsets.only(
                    top: 20,
                  ),

              child:
                  CircularProgressIndicator(),
            ),

          if (_places.isNotEmpty)
            SizedBox(
              height: 180,

              child: ListView.builder(
                itemCount:
                    _places.length,

                itemBuilder: (
                  context,
                  index,
                ) {
                  final place =
                      _places[index];

                  return ListTile(
                    leading:
                        const Icon(
                          Icons.place,
                          color: Color(
                            0xFF1565F9,
                          ),
                        ),

                    title: Text(
                      place['place_name'],
                    ),

                    subtitle: Text(
                      place['road_address_name'] ??
                          '',
                    ),

                    onTap: () {
                      _selectPlace(
                        place,
                      );
                    },
                  );
                },
              ),
            ),

          /// 지도
          Expanded(
            child: Stack(
              children: [
                KakaoMap(
                  onMapCreated: (
                    controller,
                  ) {
                    _mapController =
                        controller;
                  },

                  markers: [
                    if (_selectedLatLng !=
                        null)
                      Marker(
                        markerId:
                            'selected-location',

                        latLng:
                            _selectedLatLng!,

                        width: 40,
                        height: 40,
                      ),
                  ],

                  onMarkerTap:
                      (
                        markerId,
                        latLng,
                        zoomLevel,
                      ) {},

                  onMapTap:
                      (_) {},
                ),

                /// 선택된 주소 카드
                if (_selectedAddress
                    .isNotEmpty)
                  Positioned(
                    top: 18,
                    left: 18,
                    right: 18,

                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),

                      decoration:
                          BoxDecoration(
                            color:
                                Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),

                            boxShadow: const [
                              BoxShadow(
                                color: Color(
                                  0x14000000,
                                ),

                                blurRadius:
                                    12,

                                offset:
                                    Offset(
                                      0,
                                      4,
                                    ),
                              ),
                            ],
                          ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.place,
                            color: Color(
                              0xFF1565F9,
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child: Text(
                              _selectedAddress,

                              style:
                                  const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// 선택 버튼
          SafeArea(
            top: false,

            child: Padding(
              padding:
                  const EdgeInsets.all(
                    20,
                  ),

              child: SizedBox(
                width:
                    double.infinity,

                height: 56,

                child: FilledButton(
                  onPressed:
                      _selectedLatLng ==
                              null
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                {
                                  'address':
                                      _selectedAddress,

                                  'lat':
                                      _selectedLatLng!
                                          .latitude,

                                  'lng':
                                      _selectedLatLng!
                                          .longitude,
                                },
                              );
                            },

                  style:
                      FilledButton.styleFrom(
                        backgroundColor:
                            const Color(
                              0xFF1565F9,
                            ),

                        shape:
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                    18,
                                  ),
                            ),
                      ),

                  child: const Text(
                    '이 위치 선택',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

// ── Categories ────────────────────────────────────────────────────────────────

enum LocationCategory {
  building,
  hall,
  lab,
  mosque,
  square,
  studentAffairs,
  clinic,
  security,
  studentCamp,
  military,
}

extension LocationCategoryExtension on LocationCategory {
  String get label {
    switch (this) {
      case LocationCategory.building:
        return 'Buildings';
      case LocationCategory.hall:
        return 'Halls';
      case LocationCategory.lab:
        return 'Labs';
      case LocationCategory.mosque:
        return 'Mosque';
      case LocationCategory.square:
        return 'Squares';
      case LocationCategory.studentAffairs:
        return 'Student Affairs';
      case LocationCategory.clinic:
        return 'Clinic';
      case LocationCategory.security:
        return 'Security';
      case LocationCategory.studentCamp:
        return 'Student Camp';
      case LocationCategory.military:
        return 'Military';
    }
  }

  String get emoji {
    switch (this) {
      case LocationCategory.building:
        return '🏛️';
      case LocationCategory.hall:
        return '🏫';
      case LocationCategory.lab:
        return '🔬';
      case LocationCategory.mosque:
        return '🕌';
      case LocationCategory.square:
        return '🌳';
      case LocationCategory.studentAffairs:
        return '🎓';
      case LocationCategory.clinic:
        return '🏥';
      case LocationCategory.security:
        return '🔒';
      case LocationCategory.studentCamp:
        return '⛺';
      case LocationCategory.military:
        return '🪖';
    }
  }

  Color get color {
    switch (this) {
      case LocationCategory.building:
        return const Color(0xFF185FA5);
      case LocationCategory.hall:
        return const Color(0xFF534AB7);
      case LocationCategory.lab:
        return const Color(0xFF3B6D11);
      case LocationCategory.mosque:
        return const Color(0xFF0F6E56);
      case LocationCategory.square:
        return const Color(0xFF3B6D11);
      case LocationCategory.studentAffairs:
        return const Color(0xFF534AB7);
      case LocationCategory.clinic:
        return const Color(0xFFA32D2D);
      case LocationCategory.security:
        return const Color(0xFF5F5E5A);
      case LocationCategory.studentCamp:
        return const Color(0xFF854F0B);
      case LocationCategory.military:
        return const Color(0xFF3B6D11);
    }
  }

  Color get fillColor {
    switch (this) {
      case LocationCategory.building:
        return const Color(0xFF378ADD).withOpacity(0.25);
      case LocationCategory.hall:
        return const Color(0xFF7F77DD).withOpacity(0.25);
      case LocationCategory.lab:
        return const Color(0xFF639922).withOpacity(0.25);
      case LocationCategory.mosque:
        return const Color(0xFF1D9E75).withOpacity(0.25);
      case LocationCategory.square:
        return const Color(0xFF97C459).withOpacity(0.25);
      case LocationCategory.studentAffairs:
        return const Color(0xFF7F77DD).withOpacity(0.25);
      case LocationCategory.clinic:
        return const Color(0xFFE24B4A).withOpacity(0.25);
      case LocationCategory.security:
        return const Color(0xFF888780).withOpacity(0.25);
      case LocationCategory.studentCamp:
        return const Color(0xFFEF9F27).withOpacity(0.25);
      case LocationCategory.military:
        return const Color(0xFF639922).withOpacity(0.25);
    }
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

class CampusLocation {
  final int id;
  final String name;
  final String? floor;
  final String? description;
  final LocationCategory category;
  final LatLng? centerOverride;
  final List<LatLng>? polygon;

  const CampusLocation({
    required this.id,
    required this.name,
    required this.category,
    this.floor,
    this.description,
    this.centerOverride,
    this.polygon,
  });

  LatLng get center {
    if (centerOverride != null) return centerOverride!;
    if (polygon != null && polygon!.isNotEmpty) {
      final lat =
          polygon!.map((p) => p.latitude).reduce((a, b) => a + b) /
          polygon!.length;
      final lng =
          polygon!.map((p) => p.longitude).reduce((a, b) => a + b) /
          polygon!.length;
      return LatLng(lat, lng);
    }
    return campusCenter;
  }

  Color get color => category.color;
  Color get fillColor => category.fillColor;
  String get emoji => category.emoji;
}

// ── Campus Center ─────────────────────────────────────────────────────────────

const LatLng campusCenter = LatLng(30.077432, 31.283793);

// ── Data ──────────────────────────────────────────────────────────────────────

final List<CampusLocation> campusLocations = [
  CampusLocation(
    id: 0,
    name: 'Genidi Building',
    category: LocationCategory.building,
    polygon: [
      LatLng(30.077494850846136, 31.28303076738095),
      LatLng(30.077260905156493, 31.28278889312844),
      LatLng(30.077043811077544, 31.2830568966979),
      LatLng(30.077283359319935, 31.283303693247206),
      LatLng(30.077494850846136, 31.28303076738095),
    ],
  ),

  CampusLocation(
    id: 1,
    name: 'Ain Shams University Mosque',
    category: LocationCategory.mosque,
    polygon: [
      LatLng(30.077561462316226, 31.283281777831093),
      LatLng(30.07745891451225, 31.2831809022058),
      LatLng(30.077277056144226, 31.283417644606374),
      LatLng(30.077378641994073, 31.283523865776942),
      LatLng(30.077561462316226, 31.283281777831093),
    ],
  ),

  CampusLocation(
    id: 2,
    name: 'Noah Hall',
    category: LocationCategory.hall,
    floor: 'First Floor',
    polygon: [
      LatLng(30.07814716094539, 31.284492419505085),
      LatLng(30.078039873036815, 31.284377281161625),
      LatLng(30.077922419940563, 31.28452403578501),
      LatLng(30.07803358988768, 31.28464204303529),
      LatLng(30.07814716094539, 31.284492419505085),
    ],
  ),

  CampusLocation(
    id: 3,
    name: 'Hamad Hall',
    category: LocationCategory.hall,
    floor: 'First Floor',
    polygon: [
      LatLng(30.07840517681018, 31.28416374413868),
      LatLng(30.078291930620622, 31.284048593778124),
      LatLng(30.078181133722325, 31.284189957652046),
      LatLng(30.078296586820144, 31.284310120153464),
      LatLng(30.07840517681018, 31.28416374413868),
    ],
  ),

  CampusLocation(
    id: 4,
    name: 'Security Office',
    category: LocationCategory.security,
    polygon: [
      LatLng(30.07758293837965, 31.284162359646444),
      LatLng(30.07743901906362, 31.284014525188923),
      LatLng(30.07734307273698, 31.284128480916223),
      LatLng(30.077494987711816, 31.28427631537258),
      LatLng(30.07758293837965, 31.284162359646444),
    ],
  ),

  CampusLocation(
    id: 5,
    name: 'Hilal Hall',
    category: LocationCategory.hall,
    floor: 'Ground Floor',
    polygon: [
      LatLng(30.078032593799264, 31.284368375194305),
      LatLng(30.07797056027458, 31.284305222752295),
      LatLng(30.07787012496111, 31.28442811399117),
      LatLng(30.077926250589883, 31.284499800547906),
      LatLng(30.078032593799264, 31.284368375194305),
    ],
  ),

  CampusLocation(
    id: 6,
    name: 'Hijazi Hall',
    category: LocationCategory.hall,
    floor: 'Ground Floor',
    polygon: [
      LatLng(30.0782792505253, 31.284030424286556),
      LatLng(30.07822755605288, 31.283977512779956),
      LatLng(30.078124167027, 31.28410552448841),
      LatLng(30.07817586155346, 31.284163556462033),
      LatLng(30.0782792505253, 31.284030424286556),
    ],
  ),

  CampusLocation(
    id: 7,
    name: 'Students Affairs',
    category: LocationCategory.studentAffairs,
    floor: 'Ground Floor',
    polygon: [
      LatLng(30.07830878888184, 31.283366472404452),
      LatLng(30.0782600483942, 31.283303319962414),
      LatLng(30.07810791883969, 31.28349619093484),
      LatLng(30.078162567347448, 31.283559343376766),
      LatLng(30.07830878888184, 31.283366472404452),
    ],
  ),

  CampusLocation(
    id: 8,
    name: 'The Clinic',
    category: LocationCategory.clinic,
    polygon: [
      LatLng(30.07763824067098, 31.283602016047837),
      LatLng(30.07754666699347, 31.28350643397266),
      LatLng(30.077477248181566, 31.283596895579535),
      LatLng(30.07757177591374, 31.283690770831527),
      LatLng(30.07763824067098, 31.283602016047837),
    ],
  ),

  CampusLocation(
    id: 9,
    name: 'Student Camp',
    category: LocationCategory.studentCamp,
    polygon: [
      LatLng(30.07755552896603, 31.28371295952681),
      LatLng(30.07746690920554, 31.283622497921186),
      LatLng(30.077379766363464, 31.28372832093183),
      LatLng(30.077477248181566, 31.283820489361915),
      LatLng(30.07755552896603, 31.28371295952681),
    ],
  ),

  CampusLocation(
    id: 10,
    name: 'New Faculty of Science Laboratories Building',
    category: LocationCategory.lab,
    polygon: [
      LatLng(30.07738664601517, 31.282457838737514),
      LatLng(30.077169419542855, 31.282259108848223),
      LatLng(30.077027618671693, 31.282457838737514),
      LatLng(30.07724786249031, 31.282663541605842),
      LatLng(30.07738664601517, 31.282457838737514),
    ],
  ),

  CampusLocation(
    id: 11,
    name: 'Building Materials Technology Unit',
    category: LocationCategory.lab,
    description:
        'Building Materials Technology Unit and Porous Composition of Solid Materials',
    polygon: [
      LatLng(30.077690567473127, 31.284433647627225),
      LatLng(30.077638382113662, 31.284373341913977),
      LatLng(30.07761228942418, 31.2844034947706),
      LatLng(30.077667373983616, 31.284460450165597),
      LatLng(30.077690567473127, 31.284433647627225),
    ],
  ),

  CampusLocation(
    id: 12,
    name: 'Old Chemistry and Physics Laboratories Building',
    category: LocationCategory.lab,
    polygon: [
      LatLng(30.07771376082927, 31.28268479508378),
      LatLng(30.07770796245893, 31.282379916203183),
      LatLng(30.077620986860353, 31.282379916203183),
      LatLng(30.077623886048414, 31.28246032381955),
      LatLng(30.077516616041038, 31.282467024454775),
      LatLng(30.07751371684988, 31.28260773778439),
      LatLng(30.077618087672207, 31.28260773778439),
      LatLng(30.077623886048414, 31.282688145402034),
      LatLng(30.07771376082927, 31.28268479508378),
    ],
  ),

  CampusLocation(
    id: 13,
    name: 'New Science Building',
    category: LocationCategory.building,
    description: 'Physics, Biochemistry, and College Administration',
    polygon: [
      LatLng(30.077015055247728, 31.283505620965627),
      LatLng(30.07705274491383, 31.283452015887576),
      LatLng(30.076751227181617, 31.283157187957983),
      LatLng(30.07671353740058, 31.283194041449804),
      LatLng(30.076655553093687, 31.28313373573664),
      LatLng(30.076574375007098, 31.2832275446234),
      LatLng(30.076771521673507, 31.283438614618404),
      LatLng(30.07671353740058, 31.28351232160088),
      LatLng(30.077023752864335, 31.28382725143487),
      LatLng(30.077081736954867, 31.283750194134228),
      LatLng(30.077151317819514, 31.28382725143487),
      LatLng(30.077226697033637, 31.283723391595856),
      LatLng(30.077015055247728, 31.283505620965627),
    ],
  ),

  CampusLocation(
    id: 14,
    name: 'Military Education Services',
    category: LocationCategory.military,
    polygon: [
      LatLng(30.076409119671382, 31.28411203128192),
      LatLng(30.07631344525265, 31.284011521759936),
      LatLng(30.076226468428118, 31.28409863001275),
      LatLng(30.076322142930977, 31.284205840168795),
      LatLng(30.076409119671382, 31.28411203128192),
    ],
  ),

  CampusLocation(
    id: 15,
    name: 'Square 2',
    category: LocationCategory.square,
    polygon: [
      LatLng(30.07820370709257, 31.28387448049935),
      LatLng(30.078051687145447, 31.283721718776093),
      LatLng(30.077928308465758, 31.283889756670817),
      LatLng(30.078078936867342, 31.284044126699314),
      LatLng(30.07820370709257, 31.28387448049935),
    ],
  ),

  CampusLocation(
    id: 16,
    name: 'Square 1',
    category: LocationCategory.square,
    polygon: [
      LatLng(30.077953973070308, 31.28418947385333),
      LatLng(30.077809534023373, 31.284043188804247),
      LatLng(30.077665094765507, 31.284227920565826),
      LatLng(30.077813591302657, 31.284374205614938),
      LatLng(30.077953973070308, 31.28418947385333),
    ],
  ),

  CampusLocation(
    id: 17,
    name: 'IT Unit',
    category: LocationCategory.building,
    polygon: [
      LatLng(30.077877930980605, 31.284347334841527),
      LatLng(30.077865721235796, 31.284335341610586),
      LatLng(30.077835196865422, 31.284372732273283),
      LatLng(30.077847406614907, 31.284384725505276),
      LatLng(30.077877930980605, 31.284347334841527),
    ],
  ),
];

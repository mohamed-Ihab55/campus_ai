import 'package:bloc/bloc.dart';
import 'package:campus_ai/core/helper/hex_to_color.dart';
import 'package:campus_ai/core/helper/icon_data.dart';
import 'package:campus_ai/features/service_feature/data/model/service_item.dart';
import 'package:campus_ai/features/service_feature/data/model/service_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit() : super(ServicesInitial());

  Future<void> getServices() async {
    emit(ServicesLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('services')
          .get();

      // Check if the Cubit was closed during the 'await'
      if (isClosed) return;

      final services = snapshot.docs.map((doc) {
        final model = ServiceModel.fromJson(doc.data());
        return ServiceItem(
          title: model.title,
          subtitle: model.subTitle,
          borderColor: hexToColor(model.borderColor),
          accentColor: hexToColor(model.accentColor),
          icon: getIcon(model.icon),
          route: model.route,
        );
      }).toList();

      emit(ServicesSuccess(services));
    } catch (e) {
      if (isClosed) return;
      emit(ServicesError(e.toString()));
    }
  }
}

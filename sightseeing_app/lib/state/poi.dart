import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sightseeing_app/services/api.dart';

class POICubit extends Cubit<POIResponse> {
  POICubit() : super(POIResponse.empty());

  void setPOI(POIResponse poi) => emit(poi);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/poi.dart';

class POICubit extends Cubit<POI> {
  POICubit() : super(POI.empty());

  void setPOI(POI poi) => emit(poi);
}

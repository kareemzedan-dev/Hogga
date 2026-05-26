import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../data/datasources/my_orders_remote_data_source.dart';
import '../../data/models/order_details.dart';
import '../../data/models/order_model.dart';



abstract class MyOrderRepository {
  Future<Either<Failure, List<MyOrderData>>>  getOrder({required String type});
  Future<Either<Failure, OrderDetailsData>> getOrderDetails({required int orderId});
}

class MyOrderRepositoryImpl implements MyOrderRepository {
  final MyOrdersRemoteDataSource remoteDataSource;

  MyOrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure,List<MyOrderData>>> getOrder({required String type}) async {
    try {
      final myOrders = await remoteDataSource.getOrder(type: type);
      return Right(myOrders);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure,OrderDetailsData>> getOrderDetails({required int orderId}) async {
    try {
      final myOrderDetails = await remoteDataSource.getOrderDetails(orderId: orderId);
      return Right(myOrderDetails);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

}

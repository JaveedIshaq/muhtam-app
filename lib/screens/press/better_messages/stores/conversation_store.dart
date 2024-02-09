import 'package:cirilla/service/helpers/request_helper.dart';
import 'package:cirilla/utils/debug.dart';
import 'package:mobx/mobx.dart';

import '../models/models.dart';

part 'conversation_store.g.dart';

class BMConversationStore = BMConversationStoreBase with _$BMConversationStore;

abstract class BMConversationStoreBase with Store {
  final String? key;

  // Request helper instance
  final RequestHelper _requestHelper;

  // store for handling errors
  // final ErrorStore errorStore = ErrorStore();

  // constructor:---------------------------------------------------------------
  BMConversationStoreBase(
      this._requestHelper, {
        this.key,
      }) {
    _reaction();
  }

  // store variables:-----------------------------------------------------------
  static ObservableFuture<List<BMConversation>> emptyConversationResponse = ObservableFuture.value([]);

  @observable
  ObservableFuture<List<BMConversation>?> fetchConversationsFuture = emptyConversationResponse;

  @observable
  ObservableList<BMConversation> _conversations = ObservableList<BMConversation>.of([]);

  // computed:-------------------------------------------------------------------
  @computed
  bool get loading => fetchConversationsFuture.status == FutureStatus.pending;

  @computed
  ObservableList<BMConversation> get conversations => _conversations;

  @observable
  bool pending = false;

  // actions:-------------------------------------------------------------------
  @action
  Future<List<BMConversation>?> getConversations() async {
    if (pending) {
      return ObservableList<BMConversation>.of([]);
    }

    pending = true;

    Map<String, dynamic> qs = {
      "nocache": DateTime.now().millisecondsSinceEpoch,
    };

    final future = _requestHelper.getConversationsBM(queryParameters: qs);

    fetchConversationsFuture = ObservableFuture(future);

    return future.then((data) {
      _conversations = ObservableList<BMConversation>.of(data!);

      pending = false;
      return _conversations;
    }).catchError((error) {
      pending = false;
      avoidPrint(error);
      throw error;
    });
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _reaction() {
    _disposers = [
    ];
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}

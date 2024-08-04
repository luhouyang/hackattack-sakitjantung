import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:sakitjantung/entities/noti_entity.dart';

class LLM {
  Future<String> rag(List<Document> documents, String query) async {
    final openaiApiKey = dotenv.env['OPENAI_API_KEY'];

    // 1. Create a vector store and add documents to it
    final vectorStore = MemoryVectorStore(
      embeddings: OpenAIEmbeddings(apiKey: openaiApiKey),
    );
    await vectorStore.addDocuments(documents: documents);

    // 2. Define the retrieval chain
    final retriever = vectorStore.asRetriever();
    final setupAndRetrieval = Runnable.fromMap<String>({
      'context': retriever.pipe(
        Runnable.mapInput((docs) => docs.map((d) => d.pageContent).join('\n')),
      ),
      'question': Runnable.passthrough(),
    });

    // 3. Construct a RAG prompt template
    final promptTemplate = ChatPromptTemplate.fromTemplates(const [
      (
        ChatMessageType.system,
        'You are an AI financial planning assistant that is being trained with large amount of data. Answer the question based on only the following context:\n{context}',
      ),
      (ChatMessageType.human, '{question}'),
    ]);

    // 4. Define the final chain
    final model = ChatOpenAI(
        apiKey: openaiApiKey,
        defaultOptions: ChatOpenAIOptions(
            model: "gpt-3.5-turbo", temperature: 0.7, maxTokens: 500));
    const outputParser = StringOutputParser<ChatResult>();
    final chain =
        setupAndRetrieval.pipe(promptTemplate).pipe(model).pipe(outputParser);

    // 5. Run the pipeline
    final res = await chain.invoke(query);
    print(res);
    return res;
  }

  List<dynamic> calculateSubTotal(
      List<NotificationEventEntity> snapshot, int idx) {
    double sum = 0;
    int counter = 0;
    for (var e in snapshot) {
      if (e.transactionType == 1 && e.transactionCategory == idx) {
        sum += e.amount;
        counter++;
      }
    }
    return [sum, counter];
  }

  List<dynamic> calculateSubTotaltt(List<NotificationEventEntity> snapshot) {
    double incomeSum = 0;
    double expenseSum = 0;

    for (var e in snapshot) {
      if (e.transactionType == 1) {
        expenseSum += e.amount;
      } else if (e.transactionType == 2) {
        incomeSum += e.amount;
      }
    }
    return [incomeSum, expenseSum];
  }

  Future<String> generateReport() async {
    try {
      // Retrieve data from Firebase
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('events')
          .orderBy('createAt')
          .get();

      // Convert the snapshot to a list of NotificationEventEntity
      List<NotificationEventEntity> events = snapshot.docs
          .map((doc) => NotificationEventEntity.fromMap(
              doc.data() as Map<String, dynamic>))
          .toList();

      // Perform calculations
      List<dynamic> transportationSum = calculateSubTotal(events, 0);
      List<dynamic> entertainmentSum = calculateSubTotal(events, 1);
      List<dynamic> utilitiesSum = calculateSubTotal(events, 2);
      List<dynamic> foodAndBeveragesSum = calculateSubTotal(events, 3);
      List<dynamic> othersSum = calculateSubTotal(events, 4);
      List<dynamic> cashflowSums = calculateSubTotaltt(events);

      // Format the report
      String report = '''
    Expense Report:
    ----------------
    Transportation:
      - Total: \$${transportationSum[0].toStringAsFixed(2)}
      - Count: ${transportationSum[1]}
    
    Entertainment:
      - Total: \$${entertainmentSum[0].toStringAsFixed(2)}
      - Count: ${entertainmentSum[1]}
    
    Utilities:
      - Total: \$${utilitiesSum[0].toStringAsFixed(2)}
      - Count: ${utilitiesSum[1]}
    
    Food & Beverages:
      - Total: \$${foodAndBeveragesSum[0].toStringAsFixed(2)}
      - Count: ${foodAndBeveragesSum[1]}
    
    Others:
      - Total: \$${othersSum[0].toStringAsFixed(2)}
      - Count: ${othersSum[1]}
    
    Cashflow:
    ----------------
    Income:
      - Total: \$${cashflowSums[0].toStringAsFixed(2)}
    
    Expenses:
      - Total: \$${cashflowSums[1].toStringAsFixed(2)}
    ''';

      return report;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> forecaster() async {
    String report = await generateReport();
    final openaiApiKey = dotenv.env['OPENAI_API_KEY'];
    final promptTemplate = ChatPromptTemplate.fromTemplates([
      (
        ChatMessageType.system,
        'You are an AI financial planning assistant that is being trained with large amount of data. Generate a financial forecast and recommendation based on the report {report}'
      ),
    ]);

    // 4. Define the final chain
    final model = ChatOpenAI(
        apiKey: openaiApiKey,
        defaultOptions: const ChatOpenAIOptions(
            model: "gpt-3.5-turbo", temperature: 0.7, maxTokens: 500));
    const outputParser = StringOutputParser<ChatResult>();
    final chain = promptTemplate.pipe(model).pipe(outputParser);

    // 5. Run the pipeline
    final res = await chain.invoke({'report': report});
    print(res);
    return res;
  }
}

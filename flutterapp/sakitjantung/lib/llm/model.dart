import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

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
}

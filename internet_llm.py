import os
from langchain_community.retrievers import YouRetriever
from langchain.chains import RetrievalQA
from langchain_community.chat_models import ChatOpenAI
from dotenv import load_dotenv


def ask_question(question):
    """
    Set up the You.com and OpenAI integration, and ask a question.

    """
    # Load environment variables
    load_dotenv()
    
    # Get API keys
    ydc_api_key = os.getenv("YDC_API_KEY")
    openai_api_key = os.getenv("OPENAI_API_KEY")
    
    
    
   
    # Initialize YouRetriever
    yr = YouRetriever()
        
    # Set up the model
    model = "gpt-4o"
        
    # Create the RetrievalQA chain
    qa = RetrievalQA.from_chain_type(
        llm=ChatOpenAI(model=model, api_key=openai_api_key),
        chain_type="stuff",
        retriever=yr
    )
        
    # Get the answer
    return qa.run(question)
    



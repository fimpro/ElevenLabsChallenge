from llm import LLM
from langchain_community.retrievers import YouRetriever

# yr = YouRetriever()
# print(yr.get_relevant_documents('schron piechoty nr. 20 we Wrocławiu'))
# print(yr.model_config)

# chat = LLM(model='gpt-4o', log=True)
# chat.message('jaka jest dzisiaj pogoda we Wrocławiu?', use_internet=True)
# print(yr.num_web_results)
# print(yr.get_prompts())

print(open('prompts/choose_place_1.txt', 'r').read().format(preferences='aaa', locations_formatted='bbb'))


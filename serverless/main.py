
import os
import functions_framework
from google.cloud import storage
from langchain_google_genai import GoogleGenerativeAI
from langchain_core.messages import HumanMessage, SystemMessage
from langchain.output_parsers import CommaSeparatedListOutputParser
from langchain.prompts.chat import (
    ChatPromptTemplate,
    SystemMessagePromptTemplate,
    HumanMessagePromptTemplate
)


def langchain_script(transcript_input):
    llm = GoogleGenerativeAI(model="gemini-pro")
    sys_template = """
    You are an assistant that is mainly responsible for retrieving topics talked about in a video transcript. You only do topic modeling.
    - Respond only with the topics, separated by commas.
    - Categories of a transcript include:
        - Trends: Current developments or shifts in various fields.
        - Industries: Specific sectors such as technology, healthcare, finance, etc.
        - Themes: Subjects or ideas presented in the content.
        - Business Ideas: Innovative concepts or strategies for entrepreneurship.
        - Highlights: Key points or significant takeaways from the transcript.
        - Innovations: New technologies or methods impacting a field.
        - Subjects: Key components that are implied rather than stated.
        - Opportunities: Potential areas for growth or exploration.
    - You can use the words and terminologies that are mentioned in the transcript.
    - You can define categories and functions as topics.
    - Only pull topics from the transcript. Do not use the examples.
    - Only add most accurate topics in descending order.
    - Only return up to 3 topics.
    - Do not respond with irrelevant topics to the transcript.
    - Do not include any other characters, like hyphens or numbers.

    % START OF EXAMPLES
        - Tech
        - Social media
        - Gaming
        - Cybersecurity
        - Virtual machines
        - Cloud computing
        - Weight lifting
        - Calisthenics
        - Cuisines
        - Interview tips
        - Life hacks
        - Marketing Strategies
        - Health trends
        - Sports
    % END OF EXAMPLES
    """
    system_message_prompt_map = SystemMessagePromptTemplate.from_template(sys_template)

    transcript = transcript_input
    human_template="Transcript: {input}"
    human_message_prompt_map = HumanMessagePromptTemplate.from_template(human_template)

    chat_prompt = ChatPromptTemplate.from_messages(messages=[system_message_prompt_map, human_message_prompt_map])
    output_parser = CommaSeparatedListOutputParser()

    chain = chat_prompt | llm | output_parser
    response = chain.invoke({"input": transcript})
    print(response)


# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def topics_extractor(cloud_event):
    data = cloud_event.data
    name = data["name"]
    bucket_name = data["bucket"]

    if name.endswith('.txt'):
        client = storage.Client()
        bucket = client.get_bucket(bucket_name)
        transcript_input = bucket.blob(name)
        # Read the content of the file
        transcript = transcript_input.download_as_text()
        langchain_script(transcript)
    else:
        print("The file uploaded is not in the .txt format")
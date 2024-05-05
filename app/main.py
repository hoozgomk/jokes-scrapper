from bs4 import BeautifulSoup
import requests
from fastapi import FastAPI
import uvicorn

app = FastAPI()

# Function to scrape jokes from a single page
def scrape_jokes_from_page(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    # Find elements with "quote post-content post-body"
    quote_elements = soup.find_all('div', class_='quote post-content post-body')
    return [quote.get_text(separator=' ') for quote in quote_elements]

# URL of the website
base_url = 'http://bash.org.pl/latest/'

extracted_content = []

def startup_event():
    global extracted_content
    extracted_content = []
    # Var to store the current number of jokes
    total_jokes_collected = 0

    # Var to store the current page number
    page_num = 1

    # Scrape jokes until 100
    while total_jokes_collected < 100:
        page_url = f'{base_url}?page={page_num}'
        jokes_from_page = scrape_jokes_from_page(page_url)
        if not jokes_from_page:
            break
        for idx, joke_text in enumerate(jokes_from_page, start=total_jokes_collected + 1):
            joke_text = ' '.join(joke_text.split())
            extracted_content.append({
                "joke_id": idx,
                "content": joke_text
            })
        total_jokes_collected += len(jokes_from_page)
        page_num += 1

@app.get('/jokes')
def get_jokes():
    return {"jokes": extracted_content}

startup_event()

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

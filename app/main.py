import asyncio
from bs4 import BeautifulSoup
import httpx
from fastapi import FastAPI

app = FastAPI()

# Function to scrape jokes from a single page
async def scrape_jokes_from_page(url):
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        # Find elements with "quote post-content post-body"
        quote_elements = soup.find_all('div', class_='quote post-content post-body')
        return [quote.get_text(separator=' ') for quote in quote_elements]

# URL of the website
base_url = 'http://bash.org.pl/latest/'

extracted_content = []

async def startup_event():
    global extracted_content
    extracted_content = []
    # Var to store the current number of jokes
    total_jokes_collected = 0

    # Var to store the current page number
    page_num = 1

    # Scrape jokes until 100
    while total_jokes_collected < 100:
        page_url = f'{base_url}?page={page_num}'
        jokes_from_page = await scrape_jokes_from_page(page_url)
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

    # Truncate the list to 100 jokes if more than 100 were collected
    extracted_content = extracted_content[:100]

@app.get('/jokes')
async def get_jokes():
    return {"jokes": extracted_content}

asyncio.run(startup_event())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

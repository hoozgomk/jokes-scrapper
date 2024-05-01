import asyncio
from bs4 import BeautifulSoup
import httpx
from fastapi import FastAPI

app = FastAPI()

# Function to scrape jokes from a single page asynchronously
async def scrape_jokes_from_page(url):
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        # Find all elements with class "quote post-content post-body"
        quote_elements = soup.find_all('div', class_='quote post-content post-body')
        # Extract and return the content of each joke
        return [quote.get_text(separator=' ') for quote in quote_elements]

# URL of the website
base_url = 'http://bash.org.pl/latest/'

# Initialize a list to store the extracted content
extracted_content = []

async def startup_event():
    global extracted_content
    extracted_content = []  # Initialize the list
    # Initialize a counter to keep track of the total number of jokes collected
    total_jokes_collected = 0

    # Initialize a variable to store the current page number
    page_num = 1

    # Scrape jokes until at least 100 jokes are collected
    while total_jokes_collected < 100:
        page_url = f'{base_url}?page={page_num}'
        jokes_from_page = await scrape_jokes_from_page(page_url)
        if not jokes_from_page:
            # Break the loop if there are no more jokes on the page
            break
        for idx, joke_text in enumerate(jokes_from_page, start=total_jokes_collected + 1):
            # Remove unnecessary newline characters and tabs
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

# Call the startup event directly before running the FastAPI application
asyncio.run(startup_event())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

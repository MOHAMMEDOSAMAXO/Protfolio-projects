#web scrapping to get f1 news headlines and storing it in a csv file

import pandas as pd
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from datetime import datetime





website="https://www.formula1.com/en/latest/all"

now = datetime.now()
date_format = now.strftime("%m%d%Y")
service = Service()
options = Options()
options.add_argument('--headless=new')

driver = webdriver.Chrome(service=service,options=options)
driver.get(website)

news_xpath = '// li[@class= " group w-full list-none focus-within:outline-blue-700 focus-within:bg-carbonBlack focus-within:outline focus-within:outline-2 leading-none tablet:rounded-b-2xl tablet:bg-white border-b-2 tablet:border-b-0 tablet:!border-0 tablet:py-0  bg-white hover:bg-carbonBlack focus:desktop:bg-carbonBlack        "]'

news_containers = driver.find_elements(by = 'xpath', value=news_xpath)

headlines_type = []
headlines = [] 
links = []


for news_container in news_containers:
    
    headline_type = (news_container.find_element(by = 'xpath', value = './a/figcaption/span').text)
    headline = news_container.find_element( by = 'xpath' , value = './a/figcaption/p' ).text
    link=(news_container.find_element(by = 'xpath', value = './/a').get_attribute('href'))
    headlines_type.append(headline_type)
    headlines.append(headline)
    links.append(link)

df_f1News = pd.DataFrame({"Type":headlines_type,
                          "Headline":headlines,
                          "Link":links})


df_f1News.to_csv(f"f1_headlines-{date_format}.csv")


driver.quit()
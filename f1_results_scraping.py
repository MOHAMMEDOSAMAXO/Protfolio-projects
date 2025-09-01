

'''
input the type of session you want to get either race-result or qualifying
then for the location pick one of the locations in the country_dic
'''
def get_f1_results(session_type,location):
    import pandas as pd
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.chrome.service import Service


    country_dic={'australia':1254,
             'china':1255,
             'japan':1256,
             'bahrain':1257,
             'saudi-arabia':1258,
             'miami':1259,
             'emilia-romagna':1260,
             'monaco':1261,
             'spain':1262,
             'canada':1263,
             'austria':1264,
             'great-britain':1277,
             'belgium':1265,
             'hungary':1266,
             'netherlands':1267,
             'italy':1268,
             'azerbaijan':1269,
             'singapore':1270,
             'united-states':1271,
             'mexico':1272,
             'brazil':1273,
             'las-vegas':1274,
             'qatar':1275,
             'abu-dhabi':1276}





    website=f"https://www.formula1.com/en/results/2025/races/{country_dic[location]}/{location}/{session_type}"

    service= Service()
    options=Options()
    options.add_argument('--headless=new')
    driver = webdriver.Chrome(service=service,options=options)
    driver.get(website)

    #the xpath of the table where the data will be extracted
    table_xpath = '//*[@id="maincontent"]/div/div/div[3]/div[3]/div/div/div/table'
    containers = driver.find_elements(by='xpath',value='//table[@class="f1-table f1-table-with-data w-full"]')
    print(len(containers))
    headers= []

    #loop to get the headers of the table
    for container in containers:
        header=(container.find_element(by='xpath',value='.//tr').text)
        headers.append(header)

    headers= list(map(lambda x:(x.replace('\n',',').split(',')), headers))[0]



    # now we will get the data inside the table
    num_rows = len(driver.find_elements(by='xpath', value=table_xpath + 'tr')) + 1
    num_cols = len(driver.find_elements(by='xpath', value=table_xpath + '//tbody/tr[1]/td'))+1


    table = []
    #since only 19 drivers started the spanish GP
    if location =='spain':
         num_driver=20

    else:
         num_driver= 21
         
    for row in range(1,num_driver):
            row_data = []
            for col in range(1, num_cols):
                text = driver.find_element(by='xpath', value=f'{table_xpath}//tbody/tr[{row}]/td[{col}]').text
                row_data.append(text)
            table.append(row_data)
    df = pd.DataFrame(table)

    if session_type == 'qualifying':
        headers=['POS','NO', 'DRIVER', 'NAN', 'Q1', 'Q2', 'Q3', 'LAPS']

    elif session_type =='race-result':
        headers=['POS','NO','DRIVER', 'NAN','NAN', 'TIME / RETIRED',  'PTS']

    df.columns=headers
    df.drop(['NAN'],axis=1,inplace=True)
    
    df.to_csv(f"{location}_{session_type}_2025.csv",index=False)


    driver.quit()


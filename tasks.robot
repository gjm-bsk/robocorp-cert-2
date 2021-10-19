*** Settings ***
Documentation      
Library         RPA.Robocorp.Vault
Library         generate_mfa_code.py
Library         munker_datetime.py
Library         RPA.Browser.Playwright
Library         Dialogs
Library         RPA.Dialogs
Library         Collections
Library         String
Library         RPA.FileSystem
Library    RPA.Tables

*** Keywords ***

Start Browser

    Log To Console    headless=true, chromium, timeout=5s
    New Browser   chromium    headless=true
    
    #op 14-10-2021 heb ik succesvol met chromium gewerkt met ExactOnline, headless, in de cloud. 

    New Context   viewport={'width': 1920, 'height': 1080}    acceptDownloads=true    screen={'width': 1920, 'height': 1080}    userAgent=Chrome/92.0.4515.159
    Set Browser Timeout    5s

Create Outputfile for Test Purposes
    Create File    ${CURDIR}${/}output${/}test_results.csv    test

Exact Online | Login
    # Starts Exact Online Page, logs in, generates MFA code and enters that
    Log To Console    Exact Online Login

    #Vault values for login
    ${ExoCredentials}=    Get Secret    exo_credentials
    
    ${ExoEnvironment}    Set Variable    ${ExoCredentials}[environment]
    ${ExoUsername}    Set Variable    ${ExoCredentials}[username]
    ${ExoPassword}    Set Variable    ${ExoCredentials}[password]
    Log To Console    ...${ExoEnvironment}
  
    #Open URL
    New Page      http://start.exactonline.nl/
    ${PageID}=    Switch Page    CURRENT                # read Current Page ID 
    Set Global Variable    ${EOL-PAGE}    ${PageID}     # save to global variable

    #Fill in login fields and login
    Fill Text    id=LoginForm_UserName    ${ExoUsername}    #default, works with headless=false, chromium. 
    Click     id=LoginForm_btnSave
    
    Fill Text  id=LoginForm_Password    ${ExoPassword}
    Click     id=LoginForm_btnSave
    
    # MFA code
    ${code}=    Retrieve MFA Code
    Take Screenshot    EMBED  
    Exact Online | Activate Page    #could be removed?
    Wait For Elements State    id=LoginForm_Input_Key
    Fill Text         id=LoginForm_Input_Key    ${code}
   
    Keyboard Key    press    Space    # zorgt dat de inlog knop wordt geactiveerd
    Click      id=LoginForm_btnSave

    # post login checks
    #Wait For Elements State    //*[@id="MainWindow"] >>> //button[@id="btnRefresh"]
    #Wait For Elements State    //*[@id="MainWindow"] >>> //*[@id="dashboardContainer"]/div/div/div[1]/div/div/h1

    Log To Console    ...succesfully logged in into ExactOnline!

Exact Online | Activate Page
    Switch Page    ${EOL-PAGE}

EOL | Home
    Reload
    Click    //*[@id="EnhancedHome"]
    Sleep    1s

EOL | Vind Order in Orderlijst | Actie
    [Arguments]    ${Order} 
    #translation: Search for Order
    #pre-requisite: The Order list page is already opened
    Wait For Elements State    //*[@id="MainWindow"] >>> //input[@id="OrderNumber"]
    Fill Text    //*[@id="MainWindow"] >>> //input[@id="OrderNumber"]    ${Order}     # voer ordernummer in zoekveld
    Click    //*[@id="MainWindow"] >>> //button[@id="btnRefresh"]                    # druk op Verversen
    #Sleep    5    Waiting for refreshed page
    Wait For Elements State    //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr/td[2]/a
    Click        //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr/td[2]/a    # open Order (first row in result table)
    
    # Check if the correct Order is opened
    Wait For Elements State    //*[@id="MainWindow"] >>> //*[@id="OrderNumber"]
    Get Text    //*[@id="MainWindow"] >>> //*[@id="OrderNumber"]    equal    ${Order}

Exact Online | Vind Order in Orderlijst
     [Arguments]    ${Order} 
    Wait Until Keyword Succeeds    5x    2s    EOL | Vind Order in Orderlijst | Actie    ${Order}
Exact Online | Order | Update Leverdatum
    [Arguments]    ${NieuweLeverdatum}
 #   Set Variable    ${NieuweLeverdatum}    1-11-2021    #testcase, overruling Argument
    Get Text    //*[@id="MainWindow"] >>> //*[@id="DeliveryDateHeader"]
    Clear Text    //*[@id="MainWindow"] >>> //*[@id="DeliveryDateHeader"]    
    Fill Text    //*[@id="MainWindow"] >>> //*[@id="DeliveryDateHeader"]    ${NieuweLeverdatum}
    Keyboard Key    press    Enter
    Click    //*[@id="MainWindow"] >>> //*[@id="btnSave"]
    
    #Click Ja in Dialog:
    #Wait For Elements State    //*[@id="MenuPage"]/body/div[6]/div[3]/div/button[1]
    #Click    //*[@id="MenuPage"]/body/div[6]/div[3]/div/button[1]    #Ja
    
    #Aangepaste versie:
    #Pause Execution
    #Wait for Elements State    //*[@id="MenuPage"]//*[@class="ui-dialog-title-container_2" and text()="Afleverdatum"]
    #Click    //*[@id="MenuPage"]//*[@role="button" and text()="Ja"]

    #versie zonder click, maar gewoon op Enter drukken
    Sleep    1s
    Keyboard Key    press    Enter
    
    EOL | Home
Exact Online | Update Leverdatum van Order
    [Arguments]    ${Order}    ${NieuweLeverdatum}
    Log To Console    Update Leverdatum van Order ${Order} in ${NieuweLeverdatum}
    Wait Until Keyword Succeeds    5    4s    Exact Online | Navigeer naar Overzicht Alle Verkooporders
    Exact Online | Vind Order in Orderlijst    ${Order}
    Exact Online | Order | Update Leverdatum    ${NieuweLeverdatum}

Exact Online | Navigeer naar Overzicht Alle Verkooporders
    Exact Online | Activate Page
    EOL | Home
    Click    //*[@id="Sales"]/span
    #Click    //*[@id="Sales_Orders"]/div[1]/div
    Click    //*[@id="Sales_Orders"]
    Click    //*[@id="Sales_Orders"]
    #sleep     1s
    Click    //*[@id="Sales_Orders_SalesOrders_Overview"]
Exact Online | Navigeer naar Overzicht Goederenleveringen Nieuw 
    Log To Console    Exact Online | Navigeer naar Overzicht Goederenleveringen Nieuw 
    Exact Online | Activate Page
    Click    //*[@id="Sales"]/span
    Click    (//*[@id="Sales_DeliveriesAndReturns"]/div[1]/div)[1]
    Click    //*[@id="Sales_DeliveriesAndReturns_GoodsDeliveries_Create"]
    Sleep    5s
    #Take Screenshot    EMBED
    Wait For Elements State     //*[@id="MainWindow"] >>> //input[@id="Warehouse_alt"]    timeout=5s
    Click    //*[@id="MainWindow"] >>> //input[@id="Warehouse_alt"]

Exact Online | Selecteer Orders met Afleverdatum uiterlijk deze maand
# aanname: lijst Orders is al geopend. 
    Log To Console    Exact Online | Selecteer Orders met Afleverdatum uiterlijk deze maand
    # zet magazijn op magazijn # 1 en datum op laatste van de huidige  maand
    ${LaatsteDagMaand}=        Last Day Of The Month In Dutch Format

    Wait For Elements State     //*[@id="MainWindow"] >>> //input[@id="Warehouse_alt"]    timeout=5s
    Fill Text    //*[@id="MainWindow"] >>> //input[@id="Warehouse_alt"]    1
    Fill Text    //*[@id="MainWindow"] >>> //*[@id="DueDateRange_To"]    ${LaatsteDagMaand}
    #Pause Execution
    Click    //*[@id="MainWindow"] >>> //*[@id="btnRefresh"]

Exact Online | Vind alle Orders met Afleverwijze Planning
    # aanname: lijst Orders is al geopend. 
    # leest alle regels
    Log To Console    Exact Online | Vind alle Orders met Afleverwijze Planning

    @{Orders}=    Create List
    
    FOR    ${page}    IN RANGE    1      9999999
        Log To Console    - Pagina ${page}
        # go through all pages and retrieve Order, Afleverwijze(=DeliveryType) from each line, in sets of 15
        FOR    ${line}    IN RANGE  1    16

            #if the previous line was the last line of the complete set, exit loop
            ${run_state}=    Run Keyword And Return Status    Wait For Elements State    //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr[${line}]/td[2]  visible    5s    # does next line exist?
            Exit For Loop If    ${run_state} == ${FALSE}

            ${Leverwijze}=    Get Text    //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr[${line}]/td[3]
            ${Order}=         Get Text    //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr[${line}]/td[2]
            
            #Leverwijze Planning? => add to Orders
            ${lengteLeverwijze}=    Get Length    ${Leverwijze}
            ${eriseenLeverwijze}=    Evaluate       ${lengteLeverwijze} > 1
            IF  ${eriseenLeverwijze} == ${TRUE}  
                IF    "${Leverwijze}" == "Planning"
                    Append To List    ${Orders}    ${Order}
                END
            END

        END

        ${next_page}=    Evaluate    ${page} + 1
        ${run_state}=    Run Keyword And Return Status    Wait For Elements State    //*[@id="MainWindow"] >>> //*[@id="List_lv_pg_pg${next_page}"]   visible    1s     # does next page exist?
        Exit For Loop If    ${run_state} == ${FALSE}
        # next page
        Wait For Elements State    //*[@id="MainWindow"] >>> //*[@id="List_lv_pg_pg${next_page}"]
        Click    //*[@id="MainWindow"] >>> //*[@id="List_lv_pg_pg${next_page}"]
        Sleep    2s
    END

    Log To Console   Overzicht gevonden Orders:
    Log To Console   ${Orders}

    [Return]    ${Orders}

PerfectView | Login
    ${PfvCredentials}=    Get Secret    pfv_credentials
    ${PfvUsername}    Set Variable    ${PfvCredentials}[username]
    ${PfvPassword}    Set Variable    ${PfvCredentials}[password]
    New Page      https://app.perfectview.nl/
    ${PageID}=     Switch Page    CURRENT    # lees Page ID 
    Set Global Variable    ${PFV-PAGE}   ${PageID}
    Log    ${PFV-PAGE}    
    Fill Text     id=Username         ${PfvUsername}
    Fill Text     id=Password         ${PfvPassword}
    #Click         /html/body/div/div/div/div/div[2]/form/fieldset/div[4]/button
    #Click    name:button
    Click    id=Username
    Keyboard Key    press     ArrowDown
    Keyboard Key    press     ArrowDown
    Keyboard Key    press     ArrowDown
    Keyboard Key    press     ArrowDown
    Keyboard Key    press     Enter
    Wait For Elements State   //div[@name="pnlNavigationMenuItem"]//div[@name="MenuLabel" and text()="Planning"]  visible    timeout=30s 
    Log To Console    Succesfully Logged in into PerfectView 

PerfectView | Activate Page
    Switch Page    ${PFV-PAGE}

PerfectView | Ga naar Orders
    # translation: go to page Orders
    PerfectView | Activate Page
    Click    //div[@name="pnlNavigationMenuItem"]//div[@name="MenuLabel" and text()="Orders"]    # Go to Orders
    Wait For Elements State    "Goede weergave alle orders"

PerfectView | Ga naar Planning
    PerfectView | Activate Page
    Click    //div[@name="pnlNavigationMenuItem"]//div[@name="MenuLabel" and text()="Planning"]
    
PerfectView | Zoek Order in Orderlijst
    # translation: search for order in Order list
    [Arguments]    ${Order}
    Wait For Elements State    "Nieuw"    # het zoekveld wordt eerder getoond dan de nieuw knop. Dus wachten we daar even op. 
    Fill Text    //input[@name="tbSearch"]    ${Order}
    Keyboard Key    press    Enter

     ${run_state_order_opened}=    Run Keyword And Return Status    Wait For Elements State     //div[@name="btnClose"]    timeout=5s
    
    IF    ${run_state_order_opened} == ${FALSE}
        # order scherm is niet geopend, misschien omdat er meer dan 1 order aanwezig is met dat nummer?
        ${run_state_meerdere_regels}=    Run Keyword And Return Status    Wait For Elements State     //div[@col="4" and @row="1" and @role="cell"]    timeout=5s
        IF    ${run_state_meerdere_regels} == ${TRUE}
            Click    //div[@row="0"]//div[@col="7"]    clickCount=2    #double click
            Wait For Elements State     //div[@name="btnClose"]    timeout=5s
        END
    END

    Wait For Elements State    //div[@name="btnClose"]  # wait for OrderPage to be opened
    #Sleep    5s
   
Perfectview | Kopieer de daadwerkelijke leverdatum
    # translation: Daadwerkelijke leverdatum = Actual Delivery Date

    ${ActualDeliveryDate}=    Get Text    //div[@name="OHW_daadwerkelijke_leverdatum"]//div[@name="dateTimePicker"]/input
    ${LengteDatum}=    Get Length    ${ActualDeliveryDate}
    IF    ${LengteDatum} == 0
        Log    Datum is leeg
        ${ActualDeliveryDate}=    Get Text    //div[@name="startDate"]//div[@name="dateTimePicker"]/input  
    END
    [Return]    ${ActualDeliveryDate}

Perfectview | Sluit het orderscherm
    # translation: close the order window
    #Click    //div[@name="btnClose" and @id="id_355"]
    Click    //div[@name="btnClose"]

PerfectView | Kopieer Leverdatum van Order
    # translation: Copy Actual delivery date from Order
    [Arguments]    ${Order}
    PerfectView | Ga naar Planning    # hypothese: verhoogt stabiliteit
    PerfectView | Ga naar Orders
    PerfectView | Zoek Order in Orderlijst    ${Order}
    ${Leverdatum}=    Perfectview | Kopieer de daadwerkelijke leverdatum
    Perfectview | Sluit het orderscherm
    [Return]    ${Leverdatum}

Controleer alle Goederenleveringen Afleverdata
    [Arguments]    ${Orders}

    Log To Console    Controleer alle Goederenleveringen Afleverdata

    Remove File    ${CURDIR}${/}output${/}leverdata.csv    True
    Create File    ${CURDIR}${/}output${/}leverdata.csv    Order;Leverdatum\n

    ${aantalOrders}=    Get Length    ${Orders}
    FOR    ${counter}    IN RANGE    1    ${aantalOrders}
        Log To Console    Kopieer leverdatum van order ${Orders}[${counter}]
        ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    ${Orders}[${counter}]
        Append To File    ${CURDIR}${/}output${/}leverdata.csv    ${Orders}[${counter}];${Leverdatum} \n
        
    END

Registreer Afleverdata in ExactOnline
    [Arguments]     ${file}=leverdata
    Log To Console    Registreren alle opgehaalde Afleverdata in ExactOnline: ${file}.csv
    ${Orders}=       Read table from CSV    ${CURDIR}${/}output${/}${file}.csv    header=${TRUE}    delimiters=";""
    ${aantalOrders}=    Get Length    ${Orders}
    Log To Console    Te verwerken Orders in ExactOnline: ${aantalOrders}
    FOR    ${order}    IN    @{Orders}
        Log To Console    ${order}[Order] : ${order}[Leverdatum]
        Exact Online | Update Leverdatum van Order    ${order}[Order]   ${order}[Leverdatum]
    END


Retrieve MFA Code
# can be made application specific by changing mfa_key_app1 into (example) mfa_key_EOL
    ${VaultValues}=    Get Secret    exo_mfa_key
    ${The_Key}    Set Variable    ${VaultValues}[key]
    ${MFA_Value}=     Get Totp Token    ${The_Key}
    Log    ${MFA_Value} 
    [Return]    ${MFA_Value}

*** Tasks ***

Goederenlevering Controleren
    Log To Console    Start Proces Goederenlevering Controleren
    Start Browser

    PerfectView | Login
    Exact Online | Login
  
    Exact Online | Navigeer naar Overzicht Goederenleveringen Nieuw
    Exact Online | Selecteer Orders met Afleverdatum uiterlijk deze maand
    ${Orders}=    Exact Online | Vind alle Orders met Afleverwijze Planning
    
    Controleer alle Goederenleveringen Afleverdata    ${Orders}

    Registreer Afleverdata in ExactOnline

    Log To Console   Done.


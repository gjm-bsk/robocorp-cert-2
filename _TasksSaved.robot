*** Tasks ***

Proefjes
    @{list}=    Create List    one    two    three    four    five
    Append To List    ${list}    six
    Get Length    ${list}
    Log    ${list}    # ['one', 'two', 'three', 'four', 'five']
    Log    ${list}[0:6:2]    # ['one', 'three', 'five']


Maak nummer voor inlog Exact Online
    ${Code}=    Retrieve MFA Code
    Log To Console    ${Code}

Test meervoudige regels in Perfectview voor een order

    Start Browser
    PerfectView | Login
    PerfectView | Kopieer Leverdatum van Order    30159816    #deze hoort goed te gaan, komt netjes 1 resultaat voor. 
    PerfectView | Kopieer Leverdatum van Order    30154796
    
Haal Afleverdata op en plaats in testbestand
    
    Log To Console    Start Proces
    Start Browser

    PerfectView | Login
    Exact Online | Login
  

    Exact Online | Navigeer naar Overzicht Goederenleveringen Nieuw
    Exact Online | Selecteer Orders met Afleverdatum uiterlijk deze maand


    ${Orders}=    Exact Online | Vind alle Orders met Afleverwijze Planning
    
    Controleer alle Goederenleveringen Afleverdata    ${Orders}
    Log To Console   Done.


Test voor lezen regels laatste pagina

    # Log To Console    Start Proces
    # Start Browser

    # Exact Online | Login
  
    # Exact Online | Navigeer naar Overzicht Goederenleveringen Nieuw
    # Exact Online | Selecteer Orders met Afleverdatum uiterlijk deze maand
    # Log To Console    Ga naar laatste pagina (67)
    # Click    //*[@id="MainWindow"] >>> //*[@id="List_lv_pg_pg67"]
    
    # sleep    10s

    # ${line}=    Set Variable      1   
    # ${Leverwijze}=    Get Text    //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr[${line}]/td[2]
    # ${Order}=         Get Text    //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr[${line}]/td[2]

    # ${line}=    Set Variable      2  
    # ${Leverwijze}=    Get Text    //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr[${line}]/td[2]
    # ${Order}=         Get Text    //*[@id="MainWindow"] >>> //*[@id="List_lv"]/tbody/tr[${line}]/td[2]

Bulktest PerfectView | Kopieer Leverdatum van Order
    
    Start Browser
    PerfectView | Login

    FOR    ${counter}    IN RANGE    1    6
        Log To Console    Counter ${counter}
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30154796
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151004
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151054
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151538
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151539
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151541
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151542
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151547
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151550
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151551
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30151553
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30153186
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30153308
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30153311
         ${Leverdatum}=    PerfectView | Kopieer Leverdatum van Order    30153834
        
    END
    #Pause Execution
    Log    Done.

Test ExactOnline in Cloud
    
    Log To Console    Start Proces
    Start Browser


    Exact Online | Login

    Exact Online | Navigeer naar Overzicht Goederenleveringen Nieuw
    Exact Online | Selecteer Orders met Afleverdatum uiterlijk deze maand

Test Update Leverdatum in ExactOnline

    Start Browser

    Exact Online | Login

    Exact Online | Update Leverdatum van Order    1501260    1-12-2021    
    Exact Online | Update Leverdatum van Order    1501259    2-12-2021    
    Exact Online | Update Leverdatum van Order    1501258    3-12-2021    
    

Bulktest Registreer Afleverdata in ExactOnline
    Start Browser
    Exact Online | Login

    Remove File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    True
    Create File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    Order;Leverdatum\n
     
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501239;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501240;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501241;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501242;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501243;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501244;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501250;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501251;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501252;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501254;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501255;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501281;14-9-2021\n
    Append To File    ${CURDIR}${/}output${/}leverdataTestbestand.csv    1501282;14-9-2021\n


    Registreer Afleverdata in ExactOnline    leverdataTestbestand

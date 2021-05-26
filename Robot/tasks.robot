*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Playwright
Library           RPA.Dialogs
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.FileSystem
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Robocloud.Secrets

*** Variables *** 
${PROCESS_ORDERS}    ${True}            #Yes will process orders

*** Keywords ***

Open the robot order website
    [Arguments]    ${url}
    New Browser    chromium    headless=false
    New Context    viewport={'width': 1920, 'height': 1080}    acceptDownloads=true
    New Page    ${url}

User Input Order URL
    Create Form
    Add Text Input    URL    Order-Url    https://robotsparebinindustries.com/orders.csv
    &{response}    Request Response
    [Return]    ${response["Order-Url"]}

Get Orders
    [Arguments]    ${Order_URL}
    RPA.HTTP.Download    url=${Order_URL}    overwrite=True    target_file=orders.csv
    ${orders}=    Read table from CSV    orders.csv    header=True
    [Return]    ${orders}

Close the annoying modal
    Click    text="OK"    #weghalen dialoogvenster met aantal knoppen

Go to order another robot
   [Arguments]    ${url}
    Go to    ${url}

Fill the form
    [Arguments]    ${row}
    Log    ${row}[Order number]
    # Selecteer de juiste Head
    Select Options By    css=#head    value    ${row}[Head]
    # Selecteer de juiste Body
    ${BodyRadioButton}=    Catenate    SEPARATOR=    id-body-    ${row}[Body]
    Check Checkbox    //*[@id="${BodyRadioButton}"]
    # Invoer adres
    Type Text    //*[@id="address"]    ${row}[Address]
    # Invoer aantal Legs
    # identificatie van veld wijzigt van run op run, daarom vanaf Address veld naar boven navigeren met keyboard
    Keyboard Key    down    Shift
    Keyboard Key    down    Tab
    Keyboard Key    up    Shift
    Keyboard Input    type    ${row}[Legs]

Preview the robot
    # klik op preview knop
    Click    //*[@id="preview"]

Submit the order and read expected order info
    Click    //*[@id="order"]
    ${order_results_html}=    Get Property    //*[@id="receipt"]    outerHTML

Submit the order
    # klik op order knop, maar dat kan fout gaan dus meerdere pogingen
    Wait Until Keyword Succeeds    10x    1 s    Submit the order and read expected order info

Maak directory als die nog niet bestaat
    [Arguments]    ${DirectoryNaam}
    ${TargetDirectory}=    Catenate    SEPARATOR=    ${OUTPUT_DIR}${/}    ${DirectoryNaam}
    # maak directory als die nog niet bestaat
    ${DirectoryExists}=    Does Directory Exist    ${TargetDirectory}
    IF    ${DirectoryExists} == ${False}
        Create Directory    ${TargetDirectory}
    END
    [Return]    ${TargetDirectory}

Store the receipt as a PDF file
    [Arguments]    ${Ordernumber}
    # maak target naam
    ${TargetDirectory}=    Maak directory als die nog niet bestaat    receipts
    ${order_results_html}=    Get Property    //*[@id="receipt"]    outerHTML
    Html To Pdf    ${order_results_html}    ${TargetDirectory}${/}${Ordernumber}.pdf
    [Return]    ${TargetDirectory}${/}${Ordernumber}.pdf

Take a screenshot of the robot
    [Arguments]    ${Ordernumber}
    ${TargetDirectory}=    Maak directory als die nog niet bestaat    screenshots
    Take Screenshot    ${TargetDirectory}${/}${Ordernumber}    //*[@id="robot-preview-image"]
    [Return]    ${TargetDirectory}${/}${Ordernumber}.PNG

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    ${files}=    Create List
    ...    ${pdf}
    ...    ${screenshot}:x=0,y=0
    Add Files To PDF    ${files}    ${pdf}

 Create a ZIP file of the receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}receipts.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}receipts
    ...    ${zip_file_name}

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${VaultValues}=    Get Secret    website_url
    ${WEBSITE_URL}    Set Variable    ${VaultValues}[url]
    ${orderURL}=    User Input Order URL
    Open the robot order website    ${WEBSITE_URL}
    ${orders}=    Get orders    ${orderURL}
    IF    ${PROCESS_ORDERS} == ${True}
        FOR    ${row}    IN    @{orders}
            Close the annoying modal
                Fill the form    ${row}
            Preview the robot
            Submit the order
            ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
             ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
            Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
           Go to order another robot    ${WEBSITE_URL}
        END
    END
    Create a ZIP file of the receipts

Minimal task
    Log    Done.

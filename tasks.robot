*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.FileSystem
Library    RPA.Smartsheet
Library    RPA.RobotLogListener
*** Variables ***
${PDF_DIR}=    ${CURDIR}${/}temp
*** Tasks ***
Order robots from RobotSpareBin Industries Inc.
    set directories
    Open the robot order website
    order looper
    create ZIP
    [Teardown]    Close Browser
*** Keywords ***
set directories
    Create Directory    ${PDF_DIR}
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
Download CSV
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}
    ${orderdata}=    Read table from CSV    orders.csv
    Return From Keyword    ${orderdata}
order looper
    ${file}=    Download CSV
    FOR    ${i}    IN    @{file}
        close the anoying modal
        Wait Until Keyword Succeeds    5x    1 sec    fill the form    ${i}
        another one
    END
another one
    Click Button    id:order-another
close the anoying modal
    Click Button    OK
fill the form
    [Arguments]    ${row}
    Select From List By Index    head    ${row}[Head]
    IF    ${row}[Body] == 1
        Click Element    id:id-body-1
    END
    IF    ${row}[Body] == 2
        Click Element    id:id-body-2
    END
    IF    ${row}[Body] == 3
        Click Element    id:id-body-3
    END
    IF    ${row}[Body] == 4
        Click Element    id:id-body-4
    END
    IF    ${row}[Body] == 5
        Click Element    id:id-body-5
    END
    IF    ${row}[Body] == 6
        Click Element    id:id-body-6
    END
    Input text   xpath://input[@type="number"]    ${row}[Legs]
    Input Text    id:address    ${row}[Address]
    Click Button    Preview
    Click Button    id:order
    ${pdffile}=    Receipt to PDF    ${row}[Order number]
    Mute Run On Failure    take SS
    Embed SS to PDF    ${pdffile}    ${OUTPUT_DIR}${/}preview.png

Receipt to PDF
    [Arguments]    ${orderid}
    ${table}=    Get Element Attribute    id:receipt    outerHTML
    ${fullorder}=    Catenate    Order Number   ${orderid}    ${table}
    Html To Pdf    ${fullorder}    ${PDF_DIR}${/}receipt${orderid}.pdf
    Return From Keyword    ${PDF_DIR}${/}receipt${orderid}.pdf
take SS
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}preview.png
Embed SS to PDF
    #https://rpaframework.org/libraries/pdf/
    [Arguments]    ${PDF}    ${image}
    Open Pdf    ${PDF}
    ${list}=    Create List
    ...    ${PDF}
    ...    ${image}
    Add Files To Pdf    ${list}    ${PDF}
    Close Pdf
create ZIP
    ${Reciepts}=    Set Variable    ${OUTPUT_DIR}${/}PDFs.zip
    Archive Folder With Zip    ${PDF_DIR}    ${Reciepts}
cleanup Directory
    Remove Directory    ${PDF_DIR}    True
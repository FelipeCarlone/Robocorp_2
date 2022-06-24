*** Settings ***
Documentation            Esse eh o meu robo.                    

Library                  RPA.Browser.Selenium    auto_close=${FALSE}
Library                  RPA.FileSystem
Library                  RPA.HTTP             
Library                  RPA.Tables
Library                  RPA.Word.Application
Library                  RPA.Excel.Files
Library                  RPA.RobotLogListener
Library                  RPA.Robocloud.Items
Library                  RPA.PDF
Library                  RPA.Archive
Library                  RPA.Dialogs



*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${table}=     Get table
    FOR    ${row}   IN    @{table}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]    
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${row}[Order number]
        Go to order another robot

    END
    Create a ZIP file of the receipts  

*** Keywords ***
Open the robot order website
    Open Available Browser   https://robotsparebinindustries.com/#/robot-order   




#Get table
#    Add heading    Upload URL of CSV file
#    Add file input    label=Upload the CSV file with orders data    name=fileupload    file_type=(*.csv)    destination=${CURDIR}
#    ${response}=    Run dialog
#    RETURN    ${response.fileupload}[0]


Get table
    RPA.HTTP.Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${table}=     Read table from CSV    orders.csv    header=True
    RETURN    @{table}
    

Close the annoying modal
    Click Button    xpath:/html/body/div/div/div[2]/div/div/div/div/div/button[1]


Fill the form
    [Arguments]    ${row}
    Select From List By Value  head    ${row}[Head] 
    Select Radio Button    body    ${row}[Body]
    Input Text   class:form-control    ${row}[Legs]
    Input Text    address    ${row}[Address] 

Preview the robot
    Click Button    id=preview


Submit the order
    Click Button    id=order   
    Check if error

Store the receipt as a PDF file
    [Arguments]    ${row}
    ${pdf}=    Get Element Attribute    id=receipt     outerHTML   
    Html To Pdf    ${pdf}    ${CURDIR}${/}${row}\.pdf
    RETURN    ${pdf}

Take a screenshot of the robot
    [Arguments]    ${row}
    ${screenshot}=    Capture Element Screenshot    id=robot-preview        ${CURDIR}${/}${row}\.png
    RETURN    ${screenshot}
    

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${row}
    Open Pdf    ${CURDIR}${/}${row}\.pdf
    Add Watermark Image To Pdf    ${CURDIR}${/}${row}\.png    ${CURDIR}${/}${row}\.pdf
    Remove Files    ${CURDIR}${/}${row}\.png   
#${EXECDIR}

Go to order another robot
    Click Button    xpath:/html/body/div/div/div[1]/div/div[1]/div/button

Check if error
    ${A}=    Is Element Visible    id=receipt 
    IF    "${A}" == 'False'
        WHILE    ${A} == False
            Click Button    id=preview
            Click Button    id=order
            ${A}=    Is Element Visible    id=receipt
        END
    END

Create a ZIP file of the receipts
    Archive Folder With Zip     ${CURDIR}      ${CURDIR}/PDFszipado.zip    include=*.pdf


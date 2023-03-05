*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.RobotLogListener


*** Variables ***
${site_url}=    https://robotsparebinindustries.com/#/robot-order
${csv_file_url}=    https://robotsparebinindustries.com/orders.csv   

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Oepn The Robot Order Website
    ${Orders}=    Get orders

    FOR     ${row}    IN    @{Orders}
        Close the annoying modal
        Fill The Form    ${row}
        Preview the robot
        Submit the order
        Wait Until Keyword Succeeds    2s    1x    Preview the robot
        Wait Until Keyword Succeeds    2s    1x    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot  
    END
    
    Create a zip file of the receipts
    [Teardown]    Close Browser

    
*** Keywords ***
Oepn The Robot Order Website
    Open Available Browser     ${site_url}   maximized=${TRUE}
    
Close the annoying modal
    Click Element If Visible    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Get orders
    Download    ${csv_file_url}    overwrite=${TRUE}

    ${Orders}=    Read Table From CSV    %{ROBOT_ROOT}${/}orders.csv    ${TRUE}
    RETURN    ${Orders}
    

Fill The Form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    //form/div[3]/input    ${row}[Legs]
    Input Text    //form/div[4]/input    ${row}[Address]

Preview the robot
    Click Button    preview    
    Wait Until Element Is Visible    preview
    #Wait Until Keyword Succeeds    10x    0.3 sec    Submit    

Submit the order
    Click Button    order
    Wait Until Page Contains Element    receipt    

Go to order another robot
    Click Button    order-another

Store the receipt as a PDF file
     [Arguments]    ${row}
     Wait Until Element Is Visible    receipt
     ${receipt_html}=    Get Element Attribute    receipt        outerHTML
     Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts${/}order_no_${row}.pdf 
     RETURN    ${OUTPUT_DIR}${/}receipts${/}order_no_${row}.pdf 

Take a screenshot of the robot
    [Arguments]    ${row}
    Wait Until Element Is Visible    robot-preview-image
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}screenshot${/}robot_img_${row}.png
    RETURN    ${OUTPUT_DIR}${/}screenshot${/}robot_img_${row}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${robot_img}=    Create List    ${screenshot}:align=center
    Add Files To Pdf    ${robot_img}    ${pdf}    append=TRUE
    Close Pdf    ${pdf}

Create a zip file of the receipts
    ${zip_file}=    Set Variable    ${OUTPUT_DIR}PDFs.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${zip_file}







    





    
    

    


                
    



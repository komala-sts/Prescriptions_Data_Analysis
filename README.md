
# Prescriptions Data Analysis
<p align='justify'>For the second task, you should use the three csv files provided for you on Blackboard. These files are an excerpt from a larger file which is a real-world dataset released every month by the National Health Service (NHS) in England. The file provides a information on prescriptions which have been issued in England, although the extract we have provided focusses specifically on Bolton.</p>
The data includes three related tables, which are provided in three csv files:<br/>
• The Medical_Practice.csv file has 60 records and provides the names and addresses of the medical practices which have prescribed medication within Bolton. The PRACTICE_CODE column provides a unique identifier for each practice.<br/>
• The Drugs.csv file provides details of the different drugs that can be prescribed. This includes the chemical substance, and the product description. The BNF_CHAPTER_PLUS_CODE column provides a way of categorising the drugs based on the British National Formulatory (BNF) Chapter that includes the prescribed product. For example, an antibiotic such as Amoxicillin is categorised under ‘05: Infections’. TheBNF_CODE column provides a unique identifier for each drug.<br/>
• The Prescriptions.csv file provides a breakdown of each prescription. Each row corresponds to an individual prescription, and each prescription is linked to a practice via the PRACTICE_CODE and the drug via the BNF_CODE. It also specifies the quantity (the number of items in a pack) and the items (the number of packs). The PRESCRIPTION_CODE column provides a unique identifier for each prescription.<br/>
<p align='justify'>For this task, imagine you work as a database consultant for a pharmaceutical company. They want to analyse the prescribing data to understand more about the types of medication being prescribed, the organisations doing the prescribing, and the quantities prescribed.</p>
<p align='justify'>1. The first stage of your task is to create a database and import the three tables from the csv file. You should also add the necessary primary and foreign key constraints to the tables and provide a database diagram in your report which shows the three tables and their relationships. You should create the database with the name PrescriptionsDB and the tables with the following names:</p>
a. Medical_Practice<br/>
b. Drugs<br/>
c. Prescriptions<br/>
You should also leave the column names as they appear in the csv file. This is so we can re-run your code.<br/></br>
<p align='justify'>
 2. Write a query that returns details of all drugs which are in the form of tablets or capsules. You can assume that all drugs in this form will have one of these words in the BNF_DESCRIPTION column.</p>
<p align='justify'>
 3. Write a query that returns the total quantity for each of prescriptions – this is given by the number of items multiplied by the quantity. Some of the quantities are not integer values and your client has asked you to round the result to the nearest integer value.</p>
<p align='justify'>4. Write a query that returns a list of the distinct chemical substances which appear in the Drugs table (the chemical substance is listed in the CHEMICAL_SUBSTANCE_BNF_DESCR column)</p>
<p align='justify'>5. Write a query that returns the number of prescriptions for each BNF_CHAPTER_PLUS_CODE, along with the average cost for that chapter code, and the minimum and maximum prescription costs for that chapter code.</p>
<p align='justify'>6. Write a query that returns the most expensive prescription prescribed by each practice, sorted in descending order by prescription cost (the ACTUAL_COST column in the prescription table.) Return only those rows where the most expensive prescription is more than £4000. You should include the practice name in your result.</p>
<p align='justify'>7. You should also write at least five queries of your own and provide a brief explanation
of the results which each query returns. You should make use of all of the following at least once:</p>
o Nested query including use of EXISTS or IN<br/>
o Joins<br/>
o System functions<br/>
o Use of GROUP BY, HAVING and ORDER BY clauses<br/>
 

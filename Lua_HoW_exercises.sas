/* ********* PharmaSUG China 2018 ********* */
/* ****** PROC LUA Hands-On Workshop ****** */


/* Preliminary Exercise */
/* Run the data step provided to create a DM data set in the WORK library. */

DATA DM;
    ATTRIB DOMAIN  LENGTH=$2  LABEL='Domain Abbreviation';
    ATTRIB SUBJIDN LENGTH=8   LABEL='Subject Number';
    ATTRIB ARMCD   LENGTH=$20 LABEL='Planned Arm Code';
    ATTRIB SCRFLNY LENGTH=$3  LABEL='Screen Failure Flag';
    INPUT ARMCD $ 1-12 SCRFLNY $ 14-14 SUBJIDN 16-21;
    domain = 'DM';
DATALINES;
SCRNFAIL     Y 10010
Treament_6_2   10002
Treament_3_1   10003
Treament_3_1   10005
Treament_3_1   10004
SCRNFAIL     Y 10006
Treament_6_2   10007
Treament_3_1   10008
SCRNFAIL     Y 10009
Treament_6_2   10001
;



/* Exercise 1 */
/* Use PROC LUA to write a message of your choice to the log. Declare and use one or more local variables for the message text. */

PROC LUA;
    SUBMIT;

    ENDSUBMIT;
RUN;

/* Exercise 2 */
/* Copy your code from Exercise 1 and add an "if-else" construct to it. */

PROC LUA;
    SUBMIT;

    ENDSUBMIT;
RUN;


/* Exercise 3 */
/* Set up a basic "for-loop" using i as the iterator variable. */
/* Write a message to the log using i within the message text. */
/* Add the following piece of code AFTER the loop: print(i) */
/* Does the print(i) output what you expect? */

PROC LUA;
    SUBMIT;

    ENDSUBMIT;
RUN;


/* Exercise 4 */
/* Run the following code noting the syntax and output. */

PROC LUA;
    SUBMIT;
        colours = {'red', 'blue', 'green', 'yellow', 999}
        print(colours[1], colours[5])
    ENDSUBMIT;
RUN;


/* Exercise 5 */
/* Run the following code noting the syntax and output. */
/* How does Lua know about the colours table? */

PROC LUA;
    SUBMIT;
        -- local colours = {'red', 'blue', 'green', 'yellow'}
        for i, colour in ipairs(colours) do
            print(i, colour)
        end
    ENDSUBMIT;
RUN;


/* Exercise 6 */
/* Run the following code noting the syntax and output. */
/* Note the restart and associated log message */
/* Note the various ways of accessing the table values. */

PROC LUA restart;
    SUBMIT;
        local domain = 'SE'
        sp_domains = {CO='Comments',
                      DM='Demographics',
                      SE='Subject Elements',
                      SV='Subject Visits'}
        print(sp_domains.CO)
        print(sp_domains['DM'])
        print(sp_domains[domain])
        print(sp_domains['S'..'V'])
    ENDSUBMIT;
RUN;


/* Exercise 7 */
/* Run the following code noting the syntax and output. */

PROC LUA;
    SUBMIT;
        for code, decode in pairs(sp_domains) do
            print(code, decode)
        end
    ENDSUBMIT;
RUN;


/* Exercise 8 */
/* Within Lua, subset the DM dataset you created in the Preliminary Exercise to contain screening failure subjects only. */
/* Use sas.submit with square brackets as follows (note we will reuse the code in a later exercise). */
/* Name the output data set SCREEN_FAILURES and keep the SUBJIDN variable only. */
/* Ensure SCREEN_FAILURES is sorted by SUBJIDN */
/* Hint: use PROC SORT */

PROC LUA;
    SUBMIT;
        sas.submit
        [[
          /* Your SAS code */
        ]]
    ENDSUBMIT;
RUN;


/* Exercise 9 */
/* Amend your code from Exercise 8 to use substitution via a table to pass SUBJIDN into the SAS code. */

PROC LUA;
    SUBMIT;
        sas.submit
        ([[
          /* Your SAS code, with substitution */
        ]],  )
    ENDSUBMIT;
RUN;


/* Exercise 10 */
/* Run the following code and explain the output. */

%let gr1 = Hello;
%let gr2 = how are you?;
PROC LUA;
    SUBMIT "greeting = '&gr1'";
        print(greeting..', '.."&gr2")
    ENDSUBMIT;
RUN;


/* Exercise 11 */
/* Create some Lua variables and concatenate them using your favourite SAS cat() function. */
/* Write the result to the log. */

PROC LUA;
    SUBMIT;

    ENDSUBMIT;
RUN;


/* Exercise 12 */
/* Rewrite the following code to loop through SASHELP.VTABLE and output to the log the name of each data set in the WORK library. */
/* To do so, define a WHERE-clause to subset the data set to contain observations where LIBNAME="WORK" only */

PROC LUA;
    SUBMIT;
        local dsid = sas.open('sashelp.class')
        for obs in sas.rows(dsid) do
            print(obs.name..' is '..obs['age']..' years old.')
        end
        sas.close(dsid)
    ENDSUBMIT;
RUN;


/* Exercise 13 */
/* Rewrite the following code to loop through SASHELP.VTABLE and output to the log the name of each data set in the WORK library. */
/* To do so, define a WHERE-clause to subset the data set to contain observations where LIBNAME="WORK" only */
/* Use the macro variable INLIB within the WHERE-clause. Hint: use sas.symget, and sas.catx (refer to Exercise 10) */

%LET INLIB = WORK;
PROC LUA;
    SUBMIT;
        local dsid = sas.open('sashelp.class (where=(sex = "M"))')
        while sas.next(dsid) do
            print(sas.get_value(dsid,'name')..' is '..sas.get_value(dsid,'age')..' years old.')
        end
        sas.close(dsid)
    ENDSUBMIT;
RUN;


/* Exercise 14 */
/* Follow instructions within the PROC LUA below */

PROC LUA;
    SUBMIT;
        local dsid = sas.open('sashelp.vtable (where=(libname = "WORK")))')
        for obs in sas.rows(dsid) do
            
            -- Use sas.submit to run PROC PRINT within the for-loop to output the data contained in the WORK data sets
            -- Use substitution to pass the names of the data sets to the PRINT procedure
            -- Remember that the variable obs is a table
            
        end
        sas.close(dsid)
    ENDSUBMIT;
RUN;


/* Exercise 15a */
/* Run the following code. Is the output as expected? */

PROC LUA;
    SUBMIT;
        local ds = 'SASHELP.IRIS'
        if sas.exist(ds) then
            print(ds..' exists!')
        else
            print(ds..' does not exist!')
        end
    ENDSUBMIT;
RUN;


/* Exercise 15b */
/* Run the following code. Is the output as expected? */

PROC LUA;
    SUBMIT;
        local ds = 'SASHELP.XXX'
        if sas.exist(ds) then
            print(ds..' exists!')
        else
            print(ds..' does not exist!')
        end
    ENDSUBMIT;
RUN;


/* Exercise 15c */
/* Run the following code. Explain what is happening. */

PROC LUA;
    SUBMIT;
        local ds = 'SASHELP.XXX'
        if sas.exists(ds) then
            print(ds..' exists!')
        else
            print(ds..' does not exist!')
        end
    ENDSUBMIT;
RUN;

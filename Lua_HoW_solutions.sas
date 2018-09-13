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



*### Exercise 1;
PROC LUA;
    SUBMIT;
        local t1, t2 = 'Hello Everybody!', 'Hope you enjoy the Lua HoW today!'
        print(t1..' '..t2)
    ENDSUBMIT;
RUN;


*### Exercise 2;
PROC LUA;
    SUBMIT;
        local t, hotcold = 30
        if t < 30 then
            hotcold = 'cold'
        else
            hotcold = 'hot'
        end
        print('The weather is '..hotcold..' in Beijing today!')
    ENDSUBMIT;
RUN;


*### Exercise 3;
PROC LUA;
    SUBMIT;
        for i = 1, 10 do
            print(i..' squared is '..i^2)
        end
        print(i)
    ENDSUBMIT;
RUN;


*### Exercise 4;
PROC LUA;
    SUBMIT;
        colours = {'red', 'blue', 'green', 'yellow', 999}
        print(colours[1], colours[5])
    ENDSUBMIT;
RUN;


*### Exercise 5;
PROC LUA;
    SUBMIT;
        -- local colours = {'red', 'blue', 'green', 'yellow', 999}
        for i, colour in ipairs(colours) do
            print(i, colour)
        end
        
        for i = 1, #colours do
            print(i, colours[i])
        end
    ENDSUBMIT;
RUN;


*### Exercise 6;
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


*### Exercise 7;
PROC LUA;
    SUBMIT;
        --[[
        local sp_domains = {CO='Comments',
                            DM='Demographics',
                            SE='Subject Elements',
                            SV='Subject Visits'}
        ]]
        for code, decode in pairs(sp_domains) do
            print(code, decode)
        end
    ENDSUBMIT;
RUN;


*### Exercise 8;
PROC LUA;
    SUBMIT;
        sas.submit[[
            proc sort data=DM out=SCREEN_FAILURES (keep=subjidn);
                where scrflny = 'Y';
                by subjidn;
            run;
        ]]
    ENDSUBMIT;
RUN;


*### Exercise 9;
PROC LUA;
    SUBMIT;
        sas.submit([[
            proc sort data=DM out=SCREEN_FAILURES (keep=@byvar@);
                where scrflny = 'Y';
                by @byvar@;
            run;
        ]], {byvar='subjidn'})
    ENDSUBMIT;
RUN;


*### Exercise 10;
%let gr1 = Hello;
%let gr2 = how are you?;
PROC LUA;
    SUBMIT "greeting = '&gr1'";          /* greeting is global */
        print(greeting..', '.."&gr2")
    ENDSUBMIT;
RUN;


*### Exercise 11;
PROC LUA;
    SUBMIT;
        local t1, t2 = 'I hope you are still', 'enjoying the Lua HoW!'
        print(sas.catx(' ', t1, t2))
    ENDSUBMIT;
RUN;


*### Exercise 12;
PROC LUA;
    SUBMIT;
        local dsid = sas.open('sashelp.vtable (where=(libname = "WORK")))')
        for obs in sas.rows(dsid) do
            print(obs.memname)
        end
        sas.close(dsid)
    ENDSUBMIT;
RUN;


*### Exercise 13;
%LET INLIB = WORK;
PROC LUA;
    SUBMIT;
        local dsid = sas.open(sas.cat('sashelp.vtable (where=(libname = "', sas.symget('inlib'),'"))'))
        while sas.next(dsid) do
            print(sas.get_value(dsid,'memname'))
        end
        sas.close(dsid)
    ENDSUBMIT;
RUN;


*### Exercise 14;
PROC LUA;
    SUBMIT;
        local dsid = sas.open('sashelp.vtable (where=(libname = "WORK")))')
        for obs in sas.rows(dsid) do
            sas.submit([[
                proc print data=@ds@;
                run;
            ]], {ds=obs.memname})
        end
        sas.close(dsid)
    ENDSUBMIT;
RUN;


*### Exercise 15a;
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


*### Exercise 15b;
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


*### Exercise 15c;
PROC LUA;
    SUBMIT;
        local ds = 'SASHELP.XXX'
        print('>>>', sas.exist(ds))
        print('>>>', sas.exists(ds))
        if sas.exists(ds) then
            print(ds..' exists!')
        else
            print(ds..' does not exist!')
        end
    ENDSUBMIT;
RUN;



PROC LUA;
    SUBMIT;
        local tbl = {}
        for i = 1, 10 do
            local vars = {}
            vars.n = i
            vars.n2 = i ^ 2
            tbl[i] = vars
        end
      
        print(table.tostring(tbl))
        sas.write_ds(tbl, 'squares')
      
        print(tbl[4]['n']..' squared is '..tbl[4]['n2'])
    ENDSUBMIT;
RUN;


data class1 class2;
    set sashelp.class end=eof;
    output class1;
    *if eof then age = 20;
    output class2;
run;

PROC LUA;
    SUBMIT;
        local function mycompare(ds1, ds2)
            sas.submit [[
                proc compare base=class1 comp=class2 noprint;
                run;
            ]]
            return sas.symget('sysinfo')
        end
        
        print('Comparison result is: '..mycompare('class1', 'class2'))
    ENDSUBMIT;
RUN;

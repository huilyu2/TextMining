SELECT COUNT(DISTINCT LOWER(TERM))
FROM TX_TERMS;

SELECT COUNT(DISTINCT LOWER(TERM))
FROM TX_TERMS, TX_A2_STOPWORDS
WHERE LOWER(TERM) = TX_A2_STOPWORDS.STOPWORD;

CREATE TABLE TX_TERM_LOWER AS
(
SELECT INSTANCEID, TERMID, LOWER(TERM) AS LOWERCASETERM
FROM TX_TERMS
);

CREATE TABLE TX_TERM_LOWER_DISTINCT AS
SELECT DISTINCT LOWERCASETERM AS DISTINCTTERM
FROM TX_TERM_LOWER;

DELETE FROM TX_TERM_LOWER_DISTINCT
WHERE DISTINCTTERM IN (SELECT DISTINCTTERM
                       FROM TX_TERM_LOWER_DISTINCT, TX_A2_STOPWORDS
                       WHERE DISTINCTTERM = STOPWORD);
SELECT COUNT(*)
FROM TX_TERM_LOWER_DISTINCT_NOSTOP;

CREATE TABLE TX_DF AS
SELECT DISTINCTTERM, COUNT(DISTINCT TX_TERM_LOWER.INSTANCEID) AS INSTANCENUMBER
FROM TX_TERM_LOWER_DISTINCT_NOSTOP, TX_TERM_LOWER
WHERE TX_TERM_LOWER_DISTINCT_NOSTOP.DISTINCTTERM = TX_TERM_LOWER.LOWERCASETERM
GROUP BY DISTINCTTERM
HAVING COUNT(DISTINCT TX_TERM_LOWER.INSTANCEID)>1
ORDER BY COUNT(DISTINCT TX_TERM_LOWER.INSTANCEID) DESC;

SELECT COUNT(*)
FROM TX_DF;

CREATE TABLE TX_TF AS
SELECT DISTINCTTERM, INSTANCEID, COUNT(TX_TERM_LOWER.LOWERCASETERM) AS TERMNUMBER
FROM TX_TERM_LOWER, TX_DF
WHERE TX_TERM_LOWER.LOWERCASETERM = TX_DF.DISTINCTTERM
GROUP BY DISTINCTTERM, INSTANCEID
ORDER BY COUNT(TX_TERM_LOWER.LOWERCASETERM) DESC;

SELECT COUNT(DISTINCT DISTINCTTERM)
FROM TX_TF;

CREATE TABLE TX_TFIDF AS
SELECT TX_TF.DISTINCTTERM, INSTANCEID, TERMNUMBER * (LOG(2,6415)-LOG(2,INSTANCENUMBER)+1) AS TFIDF
FROM TX_DF, TX_TF
WHERE TX_TF.DISTINCTTERM = TX_DF.DISTINCTTERM
ORDER BY TERMNUMBER * (LOG(2,6415)-LOG(2,INSTANCENUMBER)+1) DESC;

SELECT COUNT(*)
FROM TX_TFIDF;

CREATE TABLE TX_TFIDF_TOP AS
SELECT DISTINCT DISTINCTTERM, MAX(TFIDF) AS MAXTFIDF
FROM TX_TFIDF
GROUP BY DISTINCTTERM
ORDER BY MAX(TFIDF) DESC;

SELECT DISTINCTTERM
FROM TX_TFIDF_TOP
WHERE ROWNUM<=100;

CREATE TABLE TX_FEATURES1 (
    INSTANCEID INTEGER,
burlington INTEGER,
saudi INTEGER,
honeywell INTEGER,
gm INTEGER,
sgl INTEGER,
dome INTEGER,
wendy INTEGER,
pesch INTEGER,
csr INTEGER,
heineken INTEGER,
squibb INTEGER,
avana INTEGER,
dart INTEGER,
gillette INTEGER,
encor INTEGER,
monier INTEGER,
reebok INTEGER,
resorts INTEGER,
smc INTEGER,
gaf INTEGER,
hughes INTEGER,
uccel INTEGER,
redstone INTEGER,
sealy INTEGER,
japanese INTEGER,
jardine INTEGER,
fe INTEGER,
express INTEGER,
fleet INTEGER,
medical INTEGER,
sprint INTEGER,
etl INTEGER,
borgwarner INTEGER,
harcourt INTEGER,
renault INTEGER,
bally INTEGER,
southern INTEGER,
sumitomo INTEGER,
equatorial INTEGER,
hk INTEGER,
campeau INTEGER,
usair INTEGER,
bp INTEGER,
ge INTEGER,
proxmire INTEGER,
xerox INTEGER,
southland INTEGER,
alcan INTEGER,
marks INTEGER,
avia INTEGER,
cra INTEGER,
texas INTEGER,
purolator INTEGER,
chemical INTEGER,
emery INTEGER,
eddie INTEGER,
vw INTEGER,
wickes INTEGER,
tmoc INTEGER,
quantum INTEGER,
norcros INTEGER,
bil INTEGER,
ibm INTEGER,
sante INTEGER,
pinola INTEGER,
pantera INTEGER,
alliedlyons INTEGER,
tenneco INTEGER,
ici INTEGER,
idc INTEGER,
lucky INTEGER,
fairchild INTEGER,
santa INTEGER,
allied INTEGER,
bhp INTEGER,
calmat INTEGER,
icahn INTEGER,
keycorp INTEGER,
trailways INTEGER,
agl INTEGER,
mart INTEGER,
caesars INTEGER,
merrill INTEGER,
gencorp INTEGER,
shearson INTEGER,
twa INTEGER,
sosnoff INTEGER,
redland INTEGER,
piedmont INTEGER,
air INTEGER,
crazy INTEGER,
chrysler INTEGER,
perelman INTEGER,
royex INTEGER,
preussag INTEGER,
holdenbrown INTEGER,
schwab INTEGER,
banks INTEGER,
progressive INTEGER,
liberty INTEGER);

INSERT INTO TX_FEATURES1
SELECT *
FROM (SELECT INSTANCEID, LOWERCASETERM
      FROM TX_TERM_LOWER)
      PIVOT
      (COUNT(LOWERCASETERM)
            FOR LOWERCASETERM IN ('burlington',
'saudi',
'honeywell',
'gm',
'sgl',
'dome',
'wendy',
'pesch',
'csr',
'heineken',
'squibb',
'avana',
'dart',
'gillette',
'encor',
'monier',
'reebok',
'resorts',
'smc',
'gaf',
'hughes',
'uccel',
'redstone',
'sealy',
'japanese',
'jardine',
'fe',
'express',
'fleet',
'medical',
'sprint',
'etl',
'borg-warner',
'harcourt',
'renault',
'bally',
'southern',
'sumitomo',
'equatorial',
'hk',
'campeau',
'usair',
'bp',
'ge',
'proxmire',
'xerox',
'southland',
'alcan',
'marks',
'avia',
'cra',
'texas',
'purolator',
'chemical',
'emery',
'eddie',
'vw',
'wickes',
'tmoc',
'quantum',
'norcros',
'bil',
'ibm',
'sante',
'pinola',
'pantera',
'allied-lyons',
'tenneco',
'ici',
'idc',
'lucky',
'fairchild',
'santa',
'allied',
'bhp',
'calmat',
'icahn',
'keycorp',
'trailways',
'agl',
'mart',
'caesars',
'merrill',
'gencorp',
'shearson',
'twa',
'sosnoff',
'redland',
'piedmont',
'air',
'crazy',
'chrysler',
'perelman',
'royex',
'preussag',
'holden-brown',
'schwab',
'banks',
'progressive',
'liberty'));

select count(*)
from TX_FEATURES1;

select count(distinct TX_terms.INSTANCEID)
from TX_terms, TX_GOLDSTANDARD
where TX_TERMS.INSTANCEID = TX_GOLDSTANDARD.INSTANCEID
  AND TX_GOLDSTANDARD.EARN = 'TRUE' AND TX_GOLDSTANDARD.ACQ = 'TRUE';
  
CREATE TABLE TX_C1 AS
SELECT TX_FEATURES1.*, TX_GOLDSTANDARD.EARN, TX_GOLDSTANDARD.ACQ
FROM TX_FEATURES1
JOIN TX_GOLDSTANDARD ON TX_FEATURES1.INSTANCEID = TX_GOLDSTANDARD.INSTANCEID;

SELECT COUNT (*)
FROM TX_C1;

CREATE TABLE TX_DF_PR1 AS
SELECT DISTINCTTERM, INSTANCENUMBER/5967 AS PR1
FROM TX_DF;

CREATE TABLE TX_DF_ACQNUMBER AS
SELECT TX_DF.DISTINCTTERM, COUNT(DISTINCT TX_TERM_LOWER.INSTANCEID) AS ACQNUMBER
FROM TX_DF, TX_TERM_LOWER, TX_GOLDSTANDARD
WHERE TX_DF.DISTINCTTERM =  TX_TERM_LOWER.LOWERCASETERM AND TX_TERM_LOWER.INSTANCEID = TX_GOLDSTANDARD.INSTANCEID
      AND TX_GOLDSTANDARD.ACQ = 'TRUE' AND TX_GOLDSTANDARD.EARN = 'FALSE'
GROUP BY TX_DF.DISTINCTTERM
ORDER BY ACQNUMBER DESC;

CREATE TABLE TX_DF_NUM_PR2 AS
SELECT TX_DF.DISTINCTTERM, TX_DF_ACQNUMBER.ACQNUMBER AS ACQNUMBER
FROM TX_DF_ACQNUMBER
RIGHT OUTER JOIN TX_DF
ON TX_DF.DISTINCTTERM = TX_DF_ACQNUMBER.DISTINCTTERM;

SELECT COUNT (*)
FROM TX_DF_ACQNUMBER;

SELECT COUNT(*)
FROM TX_DF_NUM_PR2;

CREATE TABLE TX_DF_PR2 AS
SELECT TX_DF.DISTINCTTERM, ACQNUMBER/INSTANCENUMBER AS PR2
FROM TX_DF, TX_DF_NUM_PR2
WHERE TX_DF.DISTINCTTERM = TX_DF_NUM_PR2.DISTINCTTERM;

SELECT COUNT(*)
FROM TX_DF_PR1;

SELECT COUNT(*)
FROM TX_DF_PR2;

CREATE TABLE TX_DF_EARNNUMBER AS
SELECT TX_DF.DISTINCTTERM, COUNT(DISTINCT TX_TERM_LOWER.INSTANCEID) AS EARNNUMBER
FROM TX_DF, TX_TERM_LOWER, TX_GOLDSTANDARD
WHERE TX_DF.DISTINCTTERM =  TX_TERM_LOWER.LOWERCASETERM AND TX_TERM_LOWER.INSTANCEID = TX_GOLDSTANDARD.INSTANCEID
      AND TX_GOLDSTANDARD.ACQ = 'FALSE' AND TX_GOLDSTANDARD.EARN = 'TRUE'
GROUP BY TX_DF.DISTINCTTERM
ORDER BY EARNNUMBER DESC;

SELECT COUNT(*)
FROM TX_DF_EARNNUMBER;

CREATE TABLE TX_DF_NUM_PR3 AS
SELECT TX_DF.DISTINCTTERM, TX_DF_EARNNUMBER.EARNNUMBER AS EARNNUMBER
FROM TX_DF_EARNNUMBER
RIGHT OUTER JOIN TX_DF
ON TX_DF.DISTINCTTERM = TX_DF_EARNNUMBER.DISTINCTTERM;

SELECT COUNT(*)
FROM TX_DF_NUM_PR3;

CREATE TABLE TX_DF_PR3 AS
SELECT TX_DF.DISTINCTTERM, EARNNUMBER/INSTANCENUMBER AS PR3
FROM TX_DF, TX_DF_NUM_PR3
WHERE TX_DF.DISTINCTTERM = TX_DF_NUM_PR3.DISTINCTTERM;

SELECT COUNT(*)
FROM TX_DF_PR3;

CREATE TABLE TX_DF_BOTHNUMBER AS
SELECT TX_DF.DISTINCTTERM, COUNT(DISTINCT TX_TERM_LOWER.INSTANCEID) AS BOTHNUMBER
FROM TX_DF, TX_TERM_LOWER, TX_GOLDSTANDARD
WHERE TX_DF.DISTINCTTERM =  TX_TERM_LOWER.LOWERCASETERM AND TX_TERM_LOWER.INSTANCEID = TX_GOLDSTANDARD.INSTANCEID
      AND TX_GOLDSTANDARD.ACQ = 'TRUE' AND TX_GOLDSTANDARD.EARN = 'TRUE'
GROUP BY TX_DF.DISTINCTTERM
ORDER BY BOTHNUMBER DESC;

SELECT COUNT(*)
FROM TX_DF_BOTHNUMBER;

CREATE TABLE TX_DF_NUM_PR3_5 AS
SELECT TX_DF.DISTINCTTERM, TX_DF_BOTHNUMBER.BOTHNUMBER AS BOTHNUMBER
FROM TX_DF_BOTHNUMBER
RIGHT OUTER JOIN TX_DF
ON TX_DF.DISTINCTTERM = TX_DF_BOTHNUMBER.DISTINCTTERM;

SELECT COUNT(*)
FROM TX_DF_NUM_PR3_5;

CREATE TABLE TX_DF_PR3_5 AS
SELECT TX_DF.DISTINCTTERM, BOTHNUMBER/INSTANCENUMBER AS PR3_5
FROM TX_DF, TX_DF_NUM_PR3_5
WHERE TX_DF.DISTINCTTERM = TX_DF_NUM_PR3_5.DISTINCTTERM;

SELECT COUNT(*)
FROM TX_DF_PR3_5;

CREATE TABLE TX_DF_PR4 AS
SELECT DISTINCTTERM, 1 - INSTANCENUMBER/5967 AS PR4
FROM TX_DF;

SELECT COUNT(*)
FROM TX_DF_PR4;

CREATE TABLE TX_DF_PR5 AS
SELECT TX_DF.DISTINCTTERM, (2192-NVL(ACQNUMBER,0))/(5967-INSTANCENUMBER) AS PR5
FROM TX_DF, TX_DF_NUM_PR2
WHERE TX_DF.DISTINCTTERM = TX_DF_NUM_PR2.DISTINCTTERM; 

SELECT COUNT(*)
FROM TX_DF_PR5;

DROP TABLE TX_DF_PR6;
CREATE TABLE TX_DF_PR6 AS
SELECT TX_DF.DISTINCTTERM, (3757-NVL(EARNNUMBER,0))/(5967-INSTANCENUMBER) AS PR6
FROM TX_DF, TX_DF_NUM_PR3
WHERE TX_DF.DISTINCTTERM = TX_DF_NUM_PR3.DISTINCTTERM;

SELECT COUNT(*)
FROM TX_DF_PR6;

CREATE TABLE TX_DF_PR6_5 AS
SELECT TX_DF.DISTINCTTERM, (18-NVL(BOTHNUMBER,0))/(5967-INSTANCENUMBER) AS PR6_5
FROM TX_DF, TX_DF_NUM_PR3_5
WHERE TX_DF.DISTINCTTERM = TX_DF_NUM_PR3_5.DISTINCTTERM;

SELECT COUNT(*)
FROM TX_DF_PR6_5;

CREATE TABLE TX_IG AS
SELECT TX_DF_PR1.DISTINCTTERM, (-2192/5967*LOG(2,2192/5967)-3757/5967*LOG(2,3757/5967)-18/5967*LOG(2,18/5967) + PR1*(NVL(PR2,0)*LOG(2,NVL(PR2,1)) + NVL(PR3,0)*LOG(2,NVL(PR3,1)) + NVL(PR3_5,0)*LOG(2,NVL(PR3_5,1))) + PR4*(PR5*LOG(2,PR5) + PR6*LOG(2,PR6) + PR6_5*LOG(2,PR6_5))) AS IG
FROM TX_DF_PR1, TX_DF_PR2, TX_DF_PR3, TX_DF_PR3_5, TX_DF_PR4, TX_DF_PR5, TX_DF_PR6, TX_DF_PR6_5
WHERE TX_DF_PR1.DISTINCTTERM = TX_DF_PR2.DISTINCTTERM AND TX_DF_PR2.DISTINCTTERM = TX_DF_PR3.DISTINCTTERM
      AND TX_DF_PR3.DISTINCTTERM = TX_DF_PR4.DISTINCTTERM AND TX_DF_PR4.DISTINCTTERM = TX_DF_PR5.DISTINCTTERM
      AND TX_DF_PR5.DISTINCTTERM = TX_DF_PR6.DISTINCTTERM
      AND TX_DF_PR6.DISTINCTTERM = TX_DF_PR6_5.DISTINCTTERM
      AND TX_DF_PR6_5.DISTINCTTERM = TX_DF_PR3_5.DISTINCTTERM
ORDER BY IG DESC;

SELECT COUNT(*)
FROM TX_IG;

SELECT DISTINCTTERM
FROM TX_IG
WHERE ROWNUM<=105;

CREATE TABLE TX_FEATURES2 (
    INSTANCEID INTEGER,
    cts INTEGER,
shr INTEGER,
net INTEGER,
qtr INTEGER,
revs INTEGER,
note INTEGER,
loss INTEGER,
shares INTEGER,
acquire INTEGER,
acquisition INTEGER,
offer INTEGER,
buy INTEGER,
stake INTEGER,
pct INTEGER,
mths INTEGER,
agreement INTEGER,
agreed INTEGER,
avg_ INTEGER,
shrs INTEGER,
terms INTEGER,
company INTEGER,
year_ INTEGER,
profit INTEGER,
div INTEGER,
record_ INTEGER,
merger INTEGER,
sell INTEGER,
purchase INTEGER,
bid INTEGER,
unit INTEGER,
common INTEGER,
exchange_ INTEGER,
transaction_ INTEGER,
acquired INTEGER,
group_ INTEGER,
qtly INTEGER,
commission INTEGER,
prior_ INTEGER,
dividend INTEGER,
tender INTEGER,
completed INTEGER,
outstanding INTEGER,
undisclosed INTEGER,
cash INTEGER,
price INTEGER,
firm INTEGER,
securities INTEGER,
subsidiary INTEGER,
bought INTEGER,
stock INTEGER,
buys INTEGER,
subject INTEGER,
takeover INTEGER,
disclosed INTEGER,
oper INTEGER,
completes INTEGER,
investor INTEGER,
deal INTEGER,
signed INTEGER,
quarter INTEGER,
companies INTEGER,
letter INTEGER,
approval INTEGER,
proposed INTEGER,
control INTEGER,
filing INTEGER,
management INTEGER,
tax INTEGER,
held INTEGER,
sells INTEGER,
sold INTEGER,
payout INTEGER,
corp INTEGER,
definitive INTEGER,
owned INTEGER,
excludes INTEGER,
results INTEGER,
intent INTEGER,
quarterly INTEGER,
announced INTEGER,
owns INTEGER,
board INTEGER,
total INTEGER,
shareholders INTEGER,
jan INTEGER,
part INTEGER,
talks INTEGER,
includes INTEGER,
comment_ INTEGER,
proposal INTEGER,
buyout INTEGER,
made INTEGER,
holds INTEGER,
split_ INTEGER,
gain INTEGER,
principle INTEGER,
pay INTEGER,
spokesman INTEGER,
investment INTEGER,
mln INTEGER);

INSERT INTO TX_FEATURES2
SELECT *
FROM (SELECT INSTANCEID, LOWERCASETERM
      FROM TX_TERM_LOWER)
      PIVOT
      (COUNT(LOWERCASETERM)
            FOR LOWERCASETERM IN ('cts',
'shr',
'net',
'qtr',
'revs',
'note',
'loss',
'shares',
'acquire',
'acquisition',
'offer',
'buy',
'stake',
'pct',
'mths',
'agreement',
'agreed',
'avg_',
'shrs',
'terms',
'company',
'year_',
'profit',
'div',
'record_',
'merger',
'sell',
'purchase',
'bid',
'unit',
'common',
'exchange_',
'transaction_',
'acquired',
'group_',
'qtly',
'commission',
'prior_',
'dividend',
'tender',
'completed',
'outstanding',
'undisclosed',
'cash',
'price',
'firm',
'securities',
'subsidiary',
'bought',
'stock',
'buys',
'subject',
'takeover',
'disclosed',
'oper',
'completes',
'investor',
'deal',
'signed',
'quarter',
'companies',
'letter',
'approval',
'proposed',
'control',
'filing',
'management',
'tax',
'held',
'sells',
'sold',
'payout',
'corp',
'definitive',
'owned',
'excludes',
'results',
'intent',
'quarterly',
'announced',
'owns',
'board',
'total',
'shareholders',
'jan',
'part',
'talks',
'includes',
'comment_',
'proposal',
'buyout',
'made',
'holds',
'split_',
'gain',
'principle',
'pay',
'spokesman',
'investment',
'mln'));

select count(*)
from TX_FEATURES2;

CREATE TABLE TX_C2 AS
SELECT TX_FEATURES2.*, TX_GOLDSTANDARD.EARN, TX_GOLDSTANDARD.ACQ
FROM TX_FEATURES2
JOIN TX_GOLDSTANDARD ON TX_FEATURES2.INSTANCEID = TX_GOLDSTANDARD.INSTANCEID;

SELECT COUNT (*)
FROM TX_C2;

SELECT DISTINCTTERM
FROM TX_IG
WHERE ROWNUM <= 205;

CREATE TABLE TX_FEATURES3 (
    INSTANCEID INTEGER,
    cts INTEGER,
shr INTEGER,
net INTEGER,
qtr INTEGER,
revs INTEGER,
note INTEGER,
loss INTEGER,
shares INTEGER,
acquire INTEGER,
acquisition INTEGER,
offer INTEGER,
buy INTEGER,
stake INTEGER,
pct INTEGER,
mths INTEGER,
agreement INTEGER,
agreed INTEGER,
avg_ INTEGER,
shrs INTEGER,
terms INTEGER,
company INTEGER,
year_ INTEGER,
profit INTEGER,
div INTEGER,
record_ INTEGER,
merger INTEGER,
sell INTEGER,
purchase INTEGER,
bid INTEGER,
unit INTEGER,
common INTEGER,
exchange_ INTEGER,
transaction_ INTEGER,
acquired INTEGER,
group_ INTEGER,
qtly INTEGER,
commission INTEGER,
prior_ INTEGER,
dividend INTEGER,
tender INTEGER,
completed INTEGER,
outstanding INTEGER,
undisclosed INTEGER,
cash INTEGER,
price INTEGER,
firm INTEGER,
securities INTEGER,
subsidiary INTEGER,
bought INTEGER,
stock INTEGER,
buys INTEGER,
subject INTEGER,
takeover INTEGER,
disclosed INTEGER,
oper INTEGER,
completes INTEGER,
investor INTEGER,
deal INTEGER,
signed INTEGER,
quarter INTEGER,
companies INTEGER,
letter INTEGER,
approval INTEGER,
proposed INTEGER,
control INTEGER,
filing INTEGER,
management INTEGER,
tax INTEGER,
held INTEGER,
sells INTEGER,
sold INTEGER,
payout INTEGER,
corp INTEGER,
definitive INTEGER,
owned INTEGER,
excludes INTEGER,
results INTEGER,
intent INTEGER,
quarterly INTEGER,
announced INTEGER,
owns INTEGER,
board INTEGER,
total INTEGER,
shareholders INTEGER,
jan INTEGER,
part INTEGER,
talks INTEGER,
includes INTEGER,
comment_ INTEGER,
proposal INTEGER,
buyout INTEGER,
made INTEGER,
holds INTEGER,
split_ INTEGER,
gain INTEGER,
principle INTEGER,
pay INTEGER,
spokesman INTEGER,
investment INTEGER,
mln INTEGER,
discontinued INTEGER,
offered INTEGER,
extraordinary INTEGER,
led INTEGER,
market INTEGER,
seeking INTEGER,
makes INTEGER,
shareholder INTEGER,
make INTEGER,
plans INTEGER,
receive INTEGER,
holding INTEGER,
acquires INTEGER,
statement_ INTEGER,
holdings INTEGER,
week INTEGER,
reached INTEGER,
seek INTEGER,
payable INTEGER,
directors INTEGER,
worth INTEGER,
york INTEGER,
earnings INTEGER,
received INTEGER,
told INTEGER,
chairman INTEGER,
merge_ INTEGER,
income INTEGER,
international INTEGER,
ct INTEGER,
sale INTEGER,
financing INTEGER,
purchased INTEGER,
business INTEGER,
tendered INTEGER,
plc INTEGER,
sets INTEGER,
yesterday INTEGER,
periods INTEGER,
controlled INTEGER,
april INTEGER,
details INTEGER,
sees INTEGER,
approved INTEGER,
lrb INTEGER,
nil INTEGER,
rrb INTEGER,
court INTEGER,
gains INTEGER,
extended INTEGER,
today INTEGER,
investors INTEGER,
valued INTEGER,
issued INTEGER,
acquiring INTEGER,
restated INTEGER,
hold INTEGER,
option_ INTEGER,
officials INTEGER,
plan INTEGER,
rejected INTEGER,
filed INTEGER,
feb INTEGER,
division INTEGER,
entered INTEGER,
regulatory INTEGER,
offers INTEGER,
based INTEGER,
discussions INTEGER,
privately_held INTEGER,
closing INTEGER,
largest INTEGER,
days INTEGER,
figures INTEGER,
members INTEGER,
parties INTEGER,
private_ INTEGER,
interest INTEGER,
previously INTEGER,
full_ INTEGER,
firms INTEGER,
buying INTEGER,
completion INTEGER,
rights INTEGER,
ranging INTEGER,
time_ INTEGER,
amount INTEGER,
speculation INTEGER,
declared INTEGER,
airlines INTEGER,
sales INTEGER,
partnership INTEGER,
credits INTEGER,
assets INTEGER,
federal INTEGER,
including_ INTEGER,
government INTEGER,
adjusted INTEGER,
charge INTEGER,
response INTEGER);

INSERT INTO TX_FEATURES3
SELECT *
FROM (SELECT INSTANCEID, LOWERCASETERM
      FROM TX_TERM_LOWER)
      PIVOT
      (COUNT(LOWERCASETERM)
            FOR LOWERCASETERM IN ('cts',
'shr',
'net',
'qtr',
'revs',
'note',
'loss',
'shares',
'acquire',
'acquisition',
'offer',
'buy',
'stake',
'pct',
'mths',
'agreement',
'agreed',
'avg_',
'shrs',
'terms',
'company',
'year_',
'profit',
'div',
'record_',
'merger',
'sell',
'purchase',
'bid',
'unit',
'common',
'exchange_',
'transaction_',
'acquired',
'group_',
'qtly',
'commission',
'prior_',
'dividend',
'tender',
'completed',
'outstanding',
'undisclosed',
'cash',
'price',
'firm',
'securities',
'subsidiary',
'bought',
'stock',
'buys',
'subject',
'takeover',
'disclosed',
'oper',
'completes',
'investor',
'deal',
'signed',
'quarter',
'companies',
'letter',
'approval',
'proposed',
'control',
'filing',
'management',
'tax',
'held',
'sells',
'sold',
'payout',
'corp',
'definitive',
'owned',
'excludes',
'results',
'intent',
'quarterly',
'announced',
'owns',
'board',
'total',
'shareholders',
'jan',
'part',
'talks',
'includes',
'comment_',
'proposal',
'buyout',
'made',
'holds',
'split_',
'gain',
'principle',
'pay',
'spokesman',
'investment',
'mln',
'discontinued',
'offered',
'extraordinary',
'led',
'market',
'seeking',
'makes',
'shareholder',
'make',
'plans',
'receive',
'holding',
'acquires',
'statement_',
'holdings',
'week',
'reached',
'seek',
'payable',
'directors',
'worth',
'york',
'earnings',
'received',
'told',
'chairman',
'merge_',
'income',
'international',
'ct',
'sale',
'financing',
'purchased',
'business',
'tendered',
'plc',
'sets',
'yesterday',
'periods',
'controlled',
'april',
'details',
'sees',
'approved',
'lrb',
'nil',
'rrb',
'court',
'gains',
'extended',
'today',
'investors',
'valued',
'issued',
'acquiring',
'restated',
'hold',
'option_',
'officials',
'plan',
'rejected',
'filed',
'feb',
'division',
'entered',
'regulatory',
'offers',
'based',
'discussions',
'privately_held',
'closing',
'largest',
'days',
'figures',
'members',
'parties',
'private_',
'interest',
'previously',
'full_',
'firms',
'buying',
'completion',
'rights',
'ranging',
'time_',
'amount',
'speculation',
'declared',
'airlines',
'sales',
'partnership',
'credits',
'assets',
'federal',
'including_',
'government',
'adjusted',
'charge',
'response'));

select count(*)
from TX_FEATURES3;

CREATE TABLE TX_C3 AS
SELECT TX_FEATURES3.*, TX_GOLDSTANDARD.EARN, TX_GOLDSTANDARD.ACQ
FROM TX_FEATURES3
JOIN TX_GOLDSTANDARD ON TX_FEATURES3.INSTANCEID = TX_GOLDSTANDARD.INSTANCEID;

SELECT COUNT (*)
FROM TX_C3;
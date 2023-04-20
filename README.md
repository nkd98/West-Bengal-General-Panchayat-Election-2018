# West-Bengal-General-Panchayat-Election-2018
I scrapped the 2018 West Bengal Panchayat General Election Data from West Bengal State Election Commission Website. 
Link to the website: https://pgems2018.wbsec.org/PublicPages/VotingResult2018.aspx .

The website has data for candidates in Zilla Parishad, Panchayat Samity and Gram Panchayat. The extracted data contains information on Gram Panchayat candidates. 


### Description of variables: 

```sl_no``` : serial number of candidates within each Gram Panchayat ward in descending order of total vote received by the candiddate. The candidates with sl_no 1 are the winners.

```cand_name``` : Candidate Name.

```father_husband``` : Father / Husband of Candidate.

```gender``` : Gender of the Candidate.

```caste``` : Caste category of the Candidate.

```party``` : Party affiliation of the Candidate.

```votes``` : Votes in favour of the Candidate.

```gp_name``` : Gram Panchayat Name.

```ps_name``` : Panchayat Samity Name.

```zp_name``` : Zilla Parishad Name.

```ward``` : Gram Panchayat Ward Name .




## Data
Download the data in excel format: [WB election.](https://github.com/nkd98/West-Bengal-General-Panchayat-Election-2018/raw/main/WB_2018_gp.xlsx)

## Script
The programme to scrape the data is written in R. [The R script](https://github.com/nkd98/West-Bengal-General-Panchayat-Election-2018/blob/main/WBscrapGP.R).


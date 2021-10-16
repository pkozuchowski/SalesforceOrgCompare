# Salesforce Org Comparison Tool

This is simple CLI based Org comparison tool which compares both metadata (omitting Metadata API limits of 5,000 files) and data.
It's leveraging SFDX CLI, bash and GIT, so having them installed is required.


### How to compare orgs
To compare orgs, you first need to have them authorized in SFDX. For example using auth web login command: `sfdx auth:web:login -r https://test.salesforce.com -a UAT`

Once you authorize all sandboxes we want to run comparison, simply run this command in shell:

```shell
./compare.sh DEV SIT UAT PROD
```
In above script DEV SIT UAT and PROD are sfdx org aliases set during authorization.
The script will download all metadata defined in package.xml files in `packages` folder. 

To omit 5,000 files limit it may be necessary to split this into multiple package.xml files in large orgs.
The tool will fetch all of them simultaneously and unzip in corresponding ./orgs/{ALIAS} folder.

When the retrieve is finished, you can use WinMerge or other tool to compare folders or open `./orgs/gitcompare` in your Git UI Client and compare commits.


### Data Comparison
To compare data, create file with .soql extension inside `./queries` folder and save SOQL query inside. 
The tool will fetch the data from each sandbox and save it in `./orgs/{alias}/data` folder for comparison.

Note that:
* SOQL should have ORDER BY clause to make records comparable.
* You can append `__t` suffix to the file name to indicate that Tooling API should be used for query ex.  `CustomObjects__t.soql`
* Standard limit of 50,000 records apply.
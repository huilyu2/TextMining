import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.BufferedReader;

public class OrgCounter {

	public OrgCounter() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) throws IOException{
		// TODO Auto-generated method stub

		File directory = new File("C:/Documents/GSLIS/590 Text Mining/Assignment 1/Abstracts/");
		File[] listOfFiles = directory.listFiles();

        BufferedReader reader = null;
	    String line = "";
	    PrintWriter outputStream = null;
	    String outputFilename = "OrgCounter.csv";
	    TreeMap<String,Integer> counterMap = new TreeMap<String,Integer>();
	    String orgName = "";
	    TreeMap<String,Integer> amountMap = new TreeMap<String,Integer>();
	    String amountStr = "";
	    int amount = 0;
	    
	    Pattern patOrg = Pattern.compile("NSF Org.+: ([\\S]+)"); //includes null
		Matcher matOrg;
		Pattern patAmount = Pattern.compile("Total Amt.+?([0-9]+)"); 
		Matcher matAmount;
		
		for (File file : listOfFiles)
		{
			if (file.isFile())
			{
			    try
			    {
			    	reader =  new BufferedReader(new FileReader(file));
			    }
			    catch (FileNotFoundException e)
			    {
			    	System.out.println("Error opening the file " + file.getName());
			    	System.exit(0);
			    }

				while ((line = reader.readLine())!= null)
			    {
				    matOrg = patOrg.matcher(line) ;
					if (matOrg.find()) 
					{
						orgName = matOrg.group(1);
						if (!counterMap.containsKey(orgName))
				        {
				        	counterMap.put(orgName, 1);
				        }
				        else
				        {			        		
				        	int number = counterMap.get(orgName);
				        	number++;
				        	counterMap.put(orgName, number);
				        }  
						
						while ((line = reader.readLine())!= null)
						{
							matAmount = patAmount.matcher(line);
							if (matAmount.find()) 
							{
								amountStr = matAmount.group(1);
								amount = Integer.parseInt(amountStr);
								if (!amountMap.containsKey(orgName))
						        {
						        	amountMap.put(orgName, amount);
						        }
						        else
						        {			        		
						        	int number = amountMap.get(orgName);
						        	number = number + amount;
						        	amountMap.put(orgName, number);
						        }  
							}
							
						}
					}
			        
					
			    }

			}
		}

		
	    try
	    {
	    	outputStream = new PrintWriter(outputFilename);
	    	outputStream.println("NSF Organization" + "," + "Number of Awards");
	    	for (String Name : counterMap.keySet())
	    	{
	    		Integer Number = counterMap.get(Name);
	    		outputStream.println(Name + "," + Number.intValue());
	    	}
	    	outputStream.println();
	    	outputStream.println("NSF Organization" + "," + "Total Amount");
	    	for (String Name : amountMap.keySet())
	    	{
	    		Integer Number = amountMap.get(Name);
	    		outputStream.println(Name + "," + "$" + Number.intValue());
	    	}
	    }
	    catch (FileNotFoundException e)
	    {
	    	System.out.println("Error creating the file.");
	    	System.exit(0);
	    }
	    
	    
	    
	    outputStream.flush();
		outputStream.close();
	}

}

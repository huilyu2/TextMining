import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import edu.stanford.nlp.ling.CoreAnnotations;
import edu.stanford.nlp.ling.CoreAnnotations.TextAnnotation;
import edu.stanford.nlp.pipeline.Annotation;
import edu.stanford.nlp.pipeline.StanfordCoreNLP;
import edu.stanford.nlp.util.CoreMap;

import java.io.BufferedReader;

public class Tokens {

	public Tokens() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) throws IOException{
		// TODO Auto-generated method stub
		File directory = new File("C:/Documents/GSLIS/590 Text Mining/Dataset/News");
		File[] listOfFiles = directory.listFiles();

        BufferedReader reader = null;
	    String line = "";
	    PrintWriter outputStream = null;
	    String outputFilename = "TokensSub.csv";
	    String allText = "";
	    String instanceID = "";
	    String title = "";
	    boolean isearn = false;
	    boolean isacq = false;
	    
	    Pattern patID = Pattern.compile("\\<REUTERS.+NEWID=\"([0-9]+)\"\\>");
		Matcher matID;
		
		Pattern patTitle = Pattern.compile("\\<TITLE\\>(.+?)\\</TITLE\\>");
		Matcher matTitle;
		
		Pattern patBody = Pattern.compile(".+\\<BODY\\>([\\S\\s]+)");
		Matcher matBody;
		
	    try
	    {
	    	outputStream = new PrintWriter(outputFilename);
	    }
	    catch (FileNotFoundException e)
	    {
	    	System.out.println("Error creating the file.");
	    	System.exit(0);
	    }
	    
	    outputStream.println("InstanceID" + "," + "TermID" + "," + "Term");
	    
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
					if (line.startsWith("<REUTERS TOPICS=\"YES\""))
					{
						matID = patID.matcher(line);
						if (matID.find()) 
						{
							instanceID = matID.group(1);
						}
					
						while ((line = reader.readLine())!= null && !line.contains("</REUTERS>"))
						{
							if (line.startsWith("<TOPICS>"))
							{
								if (line.contains("earn"))
									isearn = true;
								if (line.contains("acq"))
									isacq = true;
							}
							if (line.startsWith("<TITLE>"))
							{
								matTitle = patTitle.matcher(line);
								if (matTitle.find()) 
								{
									title = matTitle.group(1);
									title = title.replaceAll(",", " ");
								}
							}
							if (line.contains("<BODY>"))
							{
								matBody = patBody.matcher(line);
								if (matBody.find()) 
								{
									allText = matBody.group(1) + " ";
								}
								while ((line = reader.readLine())!= null && !line.contains("</BODY>"))
								{
									allText = allText + " " + line;
									allText = allText.replaceAll(",", " ");
									allText = allText.replaceAll("[\\s]{2,}", " ");
								}
							}
						}
						
						if (isearn == true || isacq == true)
						{
							Properties props = new Properties();

							props.setProperty("annotators","tokenize, ssplit, pos, lemma");

							StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
							Annotation annotation = new Annotation(title + " " + allText);
							pipeline.annotate(annotation);
							List<CoreMap> sentences = annotation.get(CoreAnnotations.SentencesAnnotation.class);
						    int countTerm = 0;
							for (CoreMap sentence : sentences) 
							{
								for (CoreMap token : sentence.get(CoreAnnotations.TokensAnnotation.class)) 
								{
									String word = token.get(TextAnnotation.class);
									if (!word.equalsIgnoreCase("Reuter") && word.matches(".*[a-zA-Z].*"))
									{
										countTerm++;
										outputStream.println(instanceID + "," + countTerm + "," + word);
									}
								}
							}
							
						}
						allText = "";
						title = "";
						isearn = false;
						isacq = false;
					}
			    }
			}
		}
    
	    outputStream.flush();
		outputStream.close();
	}

}

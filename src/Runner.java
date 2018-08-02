import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;


import com.ampl.AMPL;
import com.ampl.DataFrame;
import com.ampl.Objective;
import com.ampl.Parameter;
import com.ampl.Variable;

public class Runner {

	private String amplFileName;
	private AMPL ampl;
	private File objLog;
	private File timeLog;
	private int id;
	private Graph graph;

	private String SAT = "sat";
	private final String SATBIN = "sat-bin";
	private final String PART = "partition-opt";
	private final String PARTBIN = "partition-opt-bin";
	long startT;
	long endT;

	public Runner(String amplFileName, int id) {
		this.amplFileName = amplFileName;
		this.id = id;
		objLog = new File("logs/objlog.txt");
		timeLog= new File("logs/timelog.txt");
		writeLog(objLog, id);
		writeLog(timeLog, id);
	}

	public void run() {
		ampl = new AMPL();
		
		solveAndLog(SAT,0,0,0, false);
//		solveAndLog(SATBIN,0,0,1, false);
	//	solveAndLog(PART,0,0,1, false);
		//solveAndLog(PARTBIN,0,0,1,false);
		solveAndLog(SAT,0,0,1, true);
//		solveAndLog(SATBIN,0,0,0, false);
//		solveAndLog(PART,0,0,0, false);
//		solveAndLog(PARTBIN,0,0,0, true);
//		double nbys = graph.n/graph.s;
//		double trivLB = Math.ceil(Math.log(nbys) / Math.log(2));
//		writelog(objLog, trivLB, true);
		ampl.close();
	}

	private void solveAndLog(String modFilePath, double lb, double ub, int lp, boolean newline ) {
		double obj;
		obj = solveAMPLModel("models/" + modFilePath + ".mod", amplFileName, lb, ub, lp);		
		writelog(timeLog, (double) (endT - startT) / 1000000000, newline);
		writelog(objLog, obj, newline);
	}
	
	private void writelog(File objLog2, double obj, boolean nl) {
			try {
				PrintWriter pw = new PrintWriter(new FileWriter(objLog2, true));
				pw.printf((objLog2 == timeLog ? "%3.1f" : "%3.4f") + (nl ? "\n" : "\t"), obj);
				pw.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	}

	private void writeLog(File objLog2, int id2) {
		try {
				PrintWriter pw = new PrintWriter(new FileWriter(objLog2, true));
				pw.printf("%8d\t",id2);
				pw.close();
		} catch (IOException e) {
				e.printStackTrace();
			}
	}

	private double solveAMPLModel(String modfileName, String dataFileName, double lb, double ub, int lp) {
		try {
			ampl.reset();
			// read ampl data file
			// set solver to cplex
			
			ampl.setOption("solver", "cplex");
			ampl.setOption("relax_integrality",Integer.toString(lp));
			// tell cplex to output stuff
			ampl.setOption("cplex_options", "mipdisplay 2 mipinterval 100");
			//ampl.setBoolOption("relax_integrality",true);
			// First solve basic model
			System.out.println("Reading sat model...");
			ampl.read(modfileName);
			ampl.readData(dataFileName);
			startT= 0;
			endT = 0;
			startT = System.nanoTime();
			ampl.solve();
			System.err.println(" TOTO JE PARAMETR TOTAL SOLVE TIME" + ampl.getOption("_total_solve_time"));
			endT = System.nanoTime();
			Objective obj = ampl.getObjective("time");
			double objval = obj.value();
			System.out.println("sat objective: " + objval);

			Variable x = ampl.getVariable("x");
			// Obtain data of variable x and display them
			DataFrame dfx = x.getValues();
			String[] headers = dfx.getHeaders();
			double[] i_s = dfx.getColumnAsDoubles(headers[0]);
			double[] j_s = dfx.getColumnAsDoubles(headers[1]);
			double[] v_s = dfx.getColumnAsDoubles(headers[2]);
			double[] xvals = dfx.getColumnAsDoubles(headers[3]);
			for (int i = 0; i < xvals.length; i++) {
				if (xvals[i] == 1.0) {
					System.out.printf("%3d %3d %3d\n", (int) i_s[i], (int) j_s[i], (int) v_s[i]);
				}
			}
			return objval;
		} catch (IOException e) {
			e.printStackTrace();
			return 0;
		} finally {
		}
	}
	
	private double fibonacciLB(int n, int s, int d) {
		int[] fib = new int[n];
		fib[0] = 0;
		fib[1] = 1;
		int k = 1;
		while (2 * fib[k] < n) {
			k++;
			for (int i= 1; i <= d; i++) {
				fib[k] += (k - i  >= 0 ? fib[k-i] : 0);
			}
		}
		for (int dd: fib) {
			System.out.println(dd + " ");
		}
		return Math.ceil(k / s);
	}
	
	public void setGraph(Graph g) {
		graph = g;
	}
}

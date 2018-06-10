import java.io.File;
import java.io.IOException;
import com.ampl.AMPL;
import com.ampl.DataFrame;
import com.ampl.Objective;
import com.ampl.Parameter;
import com.ampl.Variable;

public class Runner {

	private String amplFileName;

	public Runner(String amplFileName) {
		this.amplFileName = amplFileName;
	}

	public void run() {
		AMPL ampl = new AMPL();
		try {
			fibonacciLB(200, 1, 7);
			System.exit(0);
			
			// read ampl data file
			// set solver to cplex
			ampl.setOption("solver", "cplex");
			// tell cplex to output stuff
			ampl.setOption("cplex_options", "mipdisplay 2 mipinterval 100");
			//ampl.setBoolOption("relax_integrality",true);
			// First solve basic model
			System.out.println("Reading sat model...");
			ampl.read("models/sat.mod");
			ampl.readData(amplFileName);
			ampl.solve();
			Objective obj = ampl.getObjective("time");
			double objval = obj.value();
			System.out.println("sat objective: " + objval);
			ampl.reset();

			// Solve decision problem
			System.out.println("Reading partition model...");
			ampl.read("models/partition-apex.mod");
			ampl.readData(amplFileName);
			Parameter k = ampl.getParameter("k");
			System.out.println("Setting parameter k of the decision problem to the objective value: " + objval);
			k.set(objval);
			ampl.solve();
			
			objval = objval - 1;
			System.out.println("Setting parameter k of the decision problem to something less than obj: " + objval);
			k.set(objval - 1);
			ampl.solve();
	
//			obj = ampl.getObjective("time");
//			objval = obj.value();
//			System.out.println("partition objective: " + objval);
			
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
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			ampl.close();
		}
	}
	
	private double solveAMPLModel(File modfile, File dataFile, double lb, double ub) {
		return 0;
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
	
	
	
}

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
			// read ampl data file
			// set solver to cplex
			ampl.setOption("solver", "cplex");
			// tell cplex to output stuff
			ampl.setOption("cplex_options", "mipdisplay 2 mipinterval 100");

			// First solve basic model
			System.out.println("Reading sat model...");
			ampl.read("models/sat.mod");
			ampl.readData(amplFileName);
			ampl.solve();
			Objective obj = ampl.getObjective("time");
			double objval = obj.value();

			ampl.reset();

			// Solve decision problem
			System.out.println("Reading partition model...");
			ampl.read("models/partition.mod");
			ampl.readData(amplFileName);
			Parameter k = ampl.getParameter("k");
			System.out.println("Setting parameter k of the decision problem to the objective value: " + objval);
			k.set(objval);
			ampl.solve();
	
			Objective objPart = ampl.getObjective("zero");
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
}

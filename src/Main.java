import java.io.IOException;
import com.ampl.AMPL;
import com.ampl.DataFrame;
import com.ampl.Objective;
import com.ampl.Parameter;
import com.ampl.Variable;
public class Main {

	public static void main(String[] args) {
		AMPL ampl = new AMPL();
		try {
			ampl.read("models/sat.mod");
			ampl.readData("data/ampl00.dat");
			ampl.setOption("solver", "cplex");
			ampl.solve();
			Variable y = ampl.getVariable("y");
			Variable x = ampl.getVariable("x");
			DataFrame dfy = y.getValues();
			DataFrame dfx = x.getValues();
			System.out.println(dfy);
			System.out.println(dfx);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			ampl.close();
		}
	}

}

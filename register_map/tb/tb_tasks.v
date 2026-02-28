task finish_sim;
    begin
        $display("Simulation complete! %0d checks performed, %0d errors detected",check_cnt, error_cnt);
        if (error_cnt == 0)
            $display("Simulation result: PASS");
        else
            $display("Simulation result: FAILED");
        $finish;
    end
endtask
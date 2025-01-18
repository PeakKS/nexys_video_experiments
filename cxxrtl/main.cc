 #include <iostream>
 #include <fstream>
 #include "cxxrtl.cc"
 #include <cxxrtl/cxxrtl_vcd.h>
    
 using namespace std;
    
 int main()
 {
     cxxrtl_design::p_cxxrtl top;
     cxxrtl::debug_scopes all_debug_scopes;
     cxxrtl::debug_items all_debug_items;

     top.debug_info(&all_debug_items, &all_debug_scopes, "top ");

     cxxrtl::vcd_writer vcd;
     vcd.timescale(1, "ns");
     vcd.add_without_memories(all_debug_items);

     std::ofstream waves("waves.vcd");
    
     bool prev_led = 0;
    
     top.step();
     vcd.sample(0);
     for(int cycle=0;cycle<1000;++cycle){
    
         top.p_clk.set<bool>(false);

         top.step();
         vcd.sample(cycle * 2 + 0);

         top.p_clk.set<bool>(true);

         top.step();
         vcd.sample(cycle * 2 + 1);
    
         bool cur_led = top.p_led.get<bool>();
    
         if (cur_led != prev_led){
             cout << "cycle " << cycle << " - led: " << cur_led << endl;
         }
         prev_led = cur_led;

         waves << vcd.buffer;
         vcd.buffer.clear();
     }
 }

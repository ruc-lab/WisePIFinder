# -*- coding: iso-8859-1 -*-

import sys
# sys.path.append("/usr/local/lib/python2.7/dist-packages")
import traceback
from runtime import *
import time
import csv 
import os

OUTPUT_FILE = "wisepifinder_dump.csv" 
BUCKET_NUM = 65536

SKETCH_NAMES = ["sketch1", "sketch2", "sketch3", "sketch4"]
FIELD_NAMES = ["fp", "N", "fpart", "fsum"]

def main():
    
    
    try:
        print("Connecting to BFRT (Client ID 123)...")
        rt = bfrt_runtime(123, "wisepifinder")
        print("Connection successful.")
    except Exception as e:
        print("FATAL: Could not connect to BFRT.")
        print(e)
        sys.exit(1) 

    header = []
    column_order = [] 
    
    for sketch_name in SKETCH_NAMES:
        for field_name in FIELD_NAMES:
            full_name = "{}_{}".format(sketch_name, field_name)
            header.append(full_name)
            
            
            reg_name = "SwitchIngress.{}".format(full_name)
            column_order.append(reg_name)

    print("Attempting to open output file: {}".format(OUTPUT_FILE))

    try:
        print("\n[Phase 1] Bulk reading all registers from hardware...")
        start_time = time.time()
        
        data_cache = {} 
        
        for reg_name in column_order:
            print("  Reading {}...".format(reg_name))
            try:
                values = rt.reg_read_all(reg_name, BUCKET_NUM)
                data_cache[reg_name] = values
            except Exception as e:
                print("  [Error] Failed to read register {}: {}".format(reg_name, e))
                data_cache[reg_name] = [0] * BUCKET_NUM

        read_time = time.time() - start_time
        print("[Phase 1] Completed in {:.2f} seconds.".format(read_time))

        print("\n[Phase 2] Writing data to CSV...")
        
        with open(OUTPUT_FILE, 'wb') as f:
            writer = csv.writer(f)
            writer.writerow(header)
            
            rows_written = 0
            
            for i in range(BUCKET_NUM):
                current_row = []
                
                for reg_name in column_order:
                    val = data_cache[reg_name][i]
                    current_row.append(val)
                
                writer.writerow(current_row)
                rows_written += 1
                
                if (i + 1) % 10000 == 0:
                    print("  Written {}/{} rows...".format(i + 1, BUCKET_NUM))
            
            print("Wrote {} rows successfully.".format(rows_written))
            
    except IOError as e:
        print("[File Error] Failed to open or write CSV file: {}".format(e))
        os._exit(1)
    except Exception as e:
        print("[Unknown Error] An unexpected error occurred: {}".format(e))
        traceback.print_exc()
        os._exit(1)

    print("\n--- Success! ---")
    print("All sketch data exported to {}".format(OUTPUT_FILE))
    
    os._exit(0)


if __name__ == "__main__":
    main()

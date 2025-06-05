import subprocess           # Allows running shell commands like make run

#function to run a single UVM test using Makefile
def run_test(test_name, seed=123);
    print(f"\n🚀 Running: {test_name} (seed={seed})")

    # Execute the make run command using test and seed
    result = subprocess.run(
        ["make", "run", f"TEST={test_name}", f"SEED={seed}"],
        stdout=subprocess.PIPE,   #Captures stdout
        stderr=subprocess.PIPE    #Captures stderr
    )

    output = result.stdout.decode()     #decode byte output to string
    passed = "UVM_ERROR" not in output  #Check if test passed(no UVM_ERROR)
    return test_name, passed            #Return result

#Main function to execute all tests from smoke.list
def main():
    #Read test names from smoke.list file
    with open("smoke.list", "r") as f:
        tests = [line.strip() for line in f if line.strip() and not line.startswith("#")]

    results = []   #to store test results

    #run each test and collect its pass/fail result
    for test in tests:
        test_name, passed = run_test(test)
        results.append((test_name, passed))

    #Print final regression summary
    print("\n REGRESSION SUMMARY")
    for name, passed in results:
        status = "PASS" if passed else "FAIL"
        print(f"{name:<30} : {status}")

#run the main function if script is called directly
if __name__ == "__main__":
    main()
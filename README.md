# **SUPERMUN Dashboard Setup and Deployment Guide**

## **1. Setup**

### **Step 1: Copy Raw Data to the Dashboard Folder**
Before running the dashboard, ensure that the raw data is placed in the correct location.

#### **Option 1: Manually Copy the Files**
- Copy the raw data folder from **Dropbox** to `supermun-dashboard/data`.

#### **Option 2: Create a Symbolic Link (Recommended)**
- Open **Terminal (Command Prompt)** and run the following command (adjust the file paths to match your setup):

```sh
cd user/GitHub/supermun-dashboard
mklink /J data "C:\Users\wb614536\Dropbox\SUPERMUN dashboard\data"
```

### **Step 2: Launch RStudio**
- Open `supermun-dashboard.Rproj` in RStudio.

### **Step 3: Install Necessary Packages**
- Ensure you have `pacman` and `renv` installed.
- Run the following script to install all required packages:

```r
source("package-installation.R")
```

### **Step 4: Process Data**
- Run the following script to generate the final datasets used in the dashboard:

```r
source("code/data processing.R")
```

### **Step 5: Login to Posit Connect** *(Only from a World Bank Computer)*
- Open RStudio and navigate to: **Tools > Global Options > Publishing**.
- Click on **"Connect"** and select **"Posit Connect"**.
- Enter the server URL:  
  
  ```
  https://w0lxdshyprd1c01.worldbank.org
  ```  
  
- Click **Next**, follow the prompts to log in with your **Posit Connect username** (not your email), and complete the connection.
- Restart RStudio.

### **Step 6: Deploy the App**
After connecting to the server, you can deploy the app by running the following command in R:

```r
rsconnect::deployApp(appId = "replace with GUID for the app")
```

- Replace **GUID** with the one shown in your app: **Go to Info > Scroll down > GUID and copy it**.

**📌 Screenshot Reference:**

![Screenshot 2025-03-12 101145](https://github.com/user-attachments/assets/03488954-99cb-4978-aaa4-ece552626689)

---

## **2. How to Update the Dashboard**

### **Updating Metadata**
- To update metadata (variable units, titles, definitions), edit:  
  
  ```
  documentation/SUPERMUN Indicator List.csv
  ```  

### **Updating Data**
- When new data is added to `SUPERMUN panel.csv` or new metadata is updated, rerun:

```r
source("code/data processing.R")
```

### **Updating the Dashboard Code and Publishing**
1. Open **GitHub Desktop**:
   - Select **supermun-dashboard** under "Current repository".
   - Select **main** under "Current branch".
   - Click **Fetch origin**, then **Pull changes**.

2. Open RStudio and navigate to:
   - `app/app.Rproj`
   - Open `global.R`
   - Click **Run App** to ensure all tabs load correctly.

3. **Publishing to Posit Connect:**
   - Click **Republish**.
   - In the pop-up window, locate the **GUID** under the **Info** tab.
   - Run:

   ```r
   rsconnect::deployApp(appId = "replace with GUID for the app")
   ```

This ensures that you are publishing to the **correct** existing dashboard instead of creating a new one.

---

## **3. Notes**
- If publishing fails, ensure you have **sufficient permissions**.
- For troubleshooting, contact the **Posit Connect admin team**.

---



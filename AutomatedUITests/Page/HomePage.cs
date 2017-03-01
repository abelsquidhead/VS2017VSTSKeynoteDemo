using Microsoft.VisualStudio.TestTools.UnitTesting;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AutomatedUITests.Page
{
    class HomePage
    {

        protected IWebDriver _driver;

        public HomePage(IWebDriver driver)
        {
            _driver = driver;
        }

        protected HomePage()
        {

        }



        #region Actions
        public void Close()
        {
            _driver.Close();
            _driver.Dispose();
        }

        public HomePage BrowseToHomePage(string homePageUrl)
        {
            // browse to the home page
            _driver.Navigate().GoToUrl(homePageUrl);
            return new HomePage(_driver);
        }

        public AboutPage ClickAboutPage()
        {
            try
            {
                var aboutLink = _driver.FindElement(By.LinkText("About"));
                aboutLink.Click();
            }
            catch (Exception e)
            {
                Assert.Fail("Could not find About link: " + e.Message);
            }
            return new AboutPage(_driver);
        }


        #endregion

        public HomePage VerifyHomePageReached()
        {
            try
            {
                var aspNetH1 = _driver.FindElement(By.XPath("/html/body/div[2]/div[1]/h1"));
                Assert.AreEqual("ASP.NET", aspNetH1.Text, "could not find create new link");
            }
            catch (Exception e)
            {
                Assert.Fail("Could not find create new link and verify nutrition page reached: " + e.Message);
            }

            return this;
        }



        #region Launch selenium web driver
        public static HomePage Launch(string homePageUrl, string browser = "ie")
        {
            // based on the browser passed in, created your web driver
            IWebDriver driver = null;
            if (browser.Equals("chrome"))
            {
                driver = new ChromeDriver();
            }
            

            // set the window size of the browser and browse to the home page
            driver.Manage().Window.Size = new Size(1366, 768);
            driver.Navigate().GoToUrl(homePageUrl);
            return new HomePage(driver);
        }
        #endregion



    }

}

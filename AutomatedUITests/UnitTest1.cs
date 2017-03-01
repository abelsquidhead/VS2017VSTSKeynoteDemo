using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using AutomatedUITests.Page;

namespace AutomatedUITests
{
    [TestClass]
    public class UnitTest1
    {
        static HomePage _homePage;
        
        public UnitTest1()
        {
            
        }

        #region Setup and teardown
        [ClassInitialize]

        public static void Initialize(TestContext context)
        {


            _homePage = HomePage.Launch("chrome");
            
            //_homePage = HomePage.Launch(_homePageUrl, "phantomjs");
        }

        [ClassCleanup]
        public static void Cleanup()
        {
            // close down browser and selenium driver
            _homePage.Close();
        }
        #endregion

        #region Tests
        [TestMethod]
        [TestCategory("UITests")]
        public void BrowseToHomePageTest()
        {

            Assert.IsTrue(true);
            _homePage.BrowseToHomePage("http://vs2017launchbikeshare360d.azurewebsites.net/")
                .VerifyHomePageReached();
        }

        
        #endregion
    }
}

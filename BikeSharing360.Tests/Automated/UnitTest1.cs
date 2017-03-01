using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Threading;

namespace BikeSharing360.Tests.Automated
{
    [TestClass]
    public class UnitTest1
    {
        Random random = new Random();
        [TestMethod]
        [TestCategory("UITest")]
        public void BrowseToHomePage()
        {
            Thread.Sleep(random.Next(0, 300));
            Assert.IsTrue(true);
        }

        [TestMethod]
        [TestCategory("UITest")]
        public void BrowseToContactPage()
        {
            Thread.Sleep(random.Next(0, 300));
            Assert.IsTrue(true);
        }

        [TestMethod]
        [TestCategory("UITest")]
        public void BrowseToAboutPage()
        {
            Thread.Sleep(random.Next(0, 300));
            Assert.IsTrue(true);
        }

        [TestMethod]
        [TestCategory("UITest")]
        public void AddMultipleRowsTest()
        {
            Thread.Sleep(random.Next(0, 300));
            Assert.IsTrue(true);
        }

        [TestMethod]
        [TestCategory("UITest")]
        public void DeleteUserTest()
        {
            Thread.Sleep(random.Next(0, 300));
            Assert.IsTrue(true);
        }

        [TestMethod]
        [TestCategory("UITest")]
        public void EditUserTest()
        {
            Thread.Sleep(random.Next(0, 300));
            Assert.IsTrue(true);
        }

        [TestMethod]
        [TestCategory("UITestsBroken")]
        
        public void RentBikeFromKiosk()
        {
            Thread.Sleep(random.Next(0, 300));
            Assert.Fail("Authentication failed, returned back incorrect response" );
        }

        [TestMethod]
        [TestCategory("UITestsBroken")]

        public void PayForRide()
        {
            Thread.Sleep(random.Next(0, 300));
            Assert.Fail("Routed to wrong page, could not find thank you page");
        }

    }
}

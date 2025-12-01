DROP TABLE IF EXISTS Make;
DROP TABLE IF EXISTS Model;
DROP TABLE IF EXISTS Salesperson;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS CarSales;

CREATE TABLE Salesperson (
    UserName VARCHAR(10) PRIMARY KEY,
    Password VARCHAR(20) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
	UNIQUE(FirstName, LastName)
);

INSERT INTO Salesperson VALUES 
('jdoe', 'Pass1234', 'John', 'Doe'),
('brown', 'Passwxyz', 'Bob', 'Brown'),
('ksmith1', 'Pass5566', 'Karen', 'Smith');

CREATE TABLE Customer (
    CustomerID VARCHAR(10) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Mobile VARCHAR(20) NOT NULL
);

INSERT INTO Customer VALUES 
('c001', 'David', 'Wilson', '4455667788'),
('c899', 'Eva', 'Taylor', '5566778899'),
('c199',  'Frank', 'Anderson', '6677889900'),
('c910', 'Grace', 'Thomas', '7788990011'),
('c002',  'Stan', 'Martinez', '8899001122'),
('c233', 'Laura', 'Roberts', '9900112233'),
('c123', 'Charlie', 'Davis', '7712340011'),
('c321', 'Jane', 'Smith', '9988990011'),
('c211', 'Alice', 'Johnson', '7712222221');

CREATE TABLE Make (
    MakeCode VARCHAR(5) PRIMARY KEY,
    MakeName VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO Make VALUES ('MB', 'Mercedes Benz');
INSERT INTO Make VALUES ('TOY', 'Toyota');
INSERT INTO Make VALUES ('VW', 'Volkswagen');
INSERT INTO Make VALUES ('LEX', 'Lexus');
INSERT INTO Make VALUES ('LR', 'Land Rover');

CREATE TABLE Model (
    ModelCode VARCHAR(10) PRIMARY KEY,
    ModelName VARCHAR(20) UNIQUE NOT NULL,
    MakeCode VARCHAR(10) NOT NULL,  
    FOREIGN KEY (MakeCode) REFERENCES Make(MakeCode)
);

INSERT INTO Model (ModelCode, ModelName, MakeCode) VALUES
('aclass', 'A Class', 'MB'),
('cclass', 'C Class', 'MB'),
('eclass', 'E Class', 'MB'),
('camry', 'Camry', 'TOY'),
('corolla', 'Corolla', 'TOY'),
('rav4', 'RAV4', 'TOY'),
('defender', 'Defender', 'LR'),
('rangerover', 'Range Rover', 'LR'),
('discosport', 'Discovery Sport', 'LR'),
('golf', 'Golf', 'VW'),
('passat', 'Passat', 'VW'),
('troc', 'T Roc', 'VW'),
('ux', 'UX', 'LEX'),
('gx', 'GX', 'LEX'),
('nx', 'NX', 'LEX');

CREATE TABLE CarSales (
  CarSaleID SERIAL primary key,
  MakeCode VARCHAR(10) NOT NULL REFERENCES Make(MakeCode),
  ModelCode VARCHAR(10) NOT NULL REFERENCES Model(ModelCode),
  BuiltYear INTEGER NOT NULL CHECK (BuiltYear BETWEEN 1950 AND EXTRACT(YEAR FROM CURRENT_DATE)),
  Odometer INTEGER NOT NULL,
  Price Decimal(10,2) NOT NULL,
  IsSold Boolean NOT NULL,
  BuyerID VARCHAR(10) REFERENCES Customer,
  SalespersonID VARCHAR(10) REFERENCES Salesperson,
  SaleDate Date
);

INSERT INTO CarSales (MakeCode, ModelCode, BuiltYear, Odometer, Price, IsSold, BuyerID, SalespersonID, SaleDate) VALUES
('MB', 'cclass', 2020, 64210, 72000.00, TRUE, 'c001', 'jdoe', '01/03/2024'),
('MB', 'eclass', 2019, 31210, 89000.00, FALSE, NULL, NULL, NULL),
('TOY', 'camry', 2021, 98200, 37200.00, TRUE, 'c123', 'brown', '07/12/2023'),
('TOY', 'corolla', 2022, 65000, 35000.00, TRUE, 'c910', 'jdoe', '21/09/2024'),
('LR', 'defender', 2018, 115000, 97000.00, FALSE, NULL, NULL, NULL),
('VW', 'golf', 2023, 22000, 33000.00, TRUE, 'c233', 'jdoe', '06/11/2023'),
('LEX', 'nx', 2020, 67000, 79000.00, TRUE, 'c321', 'brown', '01/01/2025'),
('LR', 'discosport', 2021, 43080, 85000.00, TRUE, 'c211', 'ksmith1', '27/01/2021'),
('TOY', 'rav4', 2019, 92900, 48000.00, FALSE, NULL, NULL, NULL),
('MB', 'aclass', 2022, 47000, 57000.00, TRUE, 'c199', 'jdoe', '01/03/2025'),
('LEX', 'ux', 2023, 23000, 70000.00, TRUE, 'c899', 'brown', '01/01/2023'),
('VW', 'passat', 2020, 63720, 42000.00, FALSE, NULL, NULL, NULL),
('MB', 'eclass', 2021, 12000, 155000.00, TRUE, 'c002', 'ksmith1', '01/10/2024'),
('LR', 'rangerover', 2017, 60000, 128000.00, FALSE, NULL, NULL, NULL),
('TOY', 'camry', 2025, 10, 49995.00, FALSE, NULL, NULL, NULL),
('LR', 'discosport', 2022, 53000, 89900.00, FALSE, NULL, NULL, NULL),
('MB', 'cclass', 2023, 55000, 82100.00, FALSE, NULL, NULL, NULL),
('MB', 'aclass', 2025, 5, 78000.00, FALSE, NULL, NULL, NULL),
('MB', 'aclass', 2015, 8912, 12000.00, TRUE, 'c199', 'jdoe', '11/03/2020'),
('TOY', 'camry', 2024, 21000, 42000.00, FALSE, NULL, NULL, NULL),
('LEX', 'gx', 2025, 6, 128085.00, FALSE, NULL, NULL, NULL),
('MB', 'eclass', 2019, 99220, 105000.00, FALSE, NULL, NULL, NULL),
('VW', 'golf', 2023, 53849, 43000.00, FALSE, NULL, NULL, NULL),
('MB', 'cclass', 2022, 89200, 62000.00, FALSE, NULL, NULL, NULL);








CREATE OR REPLACE FUNCTION find_car_sales(search_string TEXT)
RETURNS TABLE (
    carsale_id TEXT,
    make TEXT,
    model TEXT,
    builtYear TEXT,
    odometer TEXT,
    price TEXT,
    isSold TEXT,
    sale_date TEXT,
    buyer TEXT,
    salesperson TEXT
) AS $$
BEGIN
    IF search_string IS NULL OR TRIM(search_string) = '' OR
       EXISTS (SELECT 1 FROM Salesperson WHERE LOWER(UserName) = LOWER(TRIM(search_string))) THEN
        RETURN QUERY
        SELECT cs.CarSaleID::text,
               mk.MakeName::text,
               mo.ModelName::text,
               cs.BuiltYear::text,
               cs.Odometer::text,
               cs.Price::text,
               CASE WHEN cs.IsSold THEN 'True' ELSE 'False' END AS "isSold",
               TO_CHAR(cs.SaleDate, 'DD-MM-YYYY')::text,
               (cu.FirstName || ' ' || cu.LastName)::text,
               (sp.FirstName || ' ' || sp.LastName)::text
        FROM CarSales cs
        JOIN Make mk ON cs.MakeCode = mk.MakeCode
        JOIN Model mo ON cs.ModelCode = mo.ModelCode
        LEFT JOIN Customer cu ON cs.BuyerID = cu.CustomerID
        LEFT JOIN Salesperson sp ON cs.SalespersonID = sp.UserName
        WHERE LOWER(cs.SalespersonID) = LOWER(TRIM(search_string));
    ELSE
        RETURN QUERY
        SELECT cs.CarSaleID::text,
               mk.MakeName::text,
               mo.ModelName::text,
               cs.BuiltYear::text,
               cs.Odometer::text,
               cs.Price::text,
               CASE WHEN cs.IsSold THEN 'True' ELSE 'False' END AS "isSold",
               TO_CHAR(cs.SaleDate, 'DD-MM-YYYY')::text,
               (cu.FirstName || ' ' || cu.LastName)::text,
               (sp.FirstName || ' ' || sp.LastName)::text
        FROM CarSales cs
        JOIN Make mk ON cs.MakeCode = mk.MakeCode
        JOIN Model mo ON cs.ModelCode = mo.ModelCode
        LEFT JOIN Customer cu ON cs.BuyerID = cu.CustomerID
        LEFT JOIN Salesperson sp ON cs.SalespersonID = sp.UserName
        WHERE (
            mk.MakeName ILIKE '%' || search_string || '%' OR
            mo.ModelName ILIKE '%' || search_string || '%' OR
            (cu.FirstName || ' ' || cu.LastName) ILIKE '%' || search_string || '%' OR
            (sp.FirstName || ' ' || sp.LastName) ILIKE '%' || search_string || '%'
        )
        AND NOT (cs.IsSold = TRUE AND cs.SaleDate < (CURRENT_DATE - INTERVAL '3 years'))
        ORDER BY cs.IsSold ASC, cs.SaleDate ASC, mk.MakeName ASC, mo.ModelName ASC;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_car_sale(
    update_carsaleid INTEGER,
    update_buyerid VARCHAR,
    update_salespersonid VARCHAR,
    update_saledate DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    v_buyerid VARCHAR;
    v_salespersonid VARCHAR;
BEGIN
    SELECT CustomerID INTO v_buyerid
    FROM Customer
    WHERE LOWER(CustomerID) = LOWER(update_buyerid);

    SELECT UserName INTO v_salespersonid
    FROM Salesperson
    WHERE LOWER(UserName) = LOWER(update_salespersonid);

    IF v_buyerid IS NULL OR v_salespersonid IS NULL THEN
        RETURN FALSE;
    END IF;

    UPDATE CarSales
    SET BuyerID = v_buyerid,
        SalespersonID = v_salespersonid,
        SaleDate = update_saledate,
        IsSold = TRUE
    WHERE CarSaleID = update_carsaleid;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_sales_summary()
RETURNS TABLE(
    Make TEXT,
    Model TEXT,
    "Available Units" TEXT,
    "Sold Units" TEXT,
    "Total Sales $" TEXT,
    "Last Purchased At" TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        make.makename::TEXT AS Make, 
        model.modelname::TEXT AS Model, 
        (count(*) - count(case when carsales.issold = 'True' THEN 1 else NULL end))::TEXT AS "Available Units", 
        (count(case when carsales.issold = 'True' THEN 1 else NULL end))::TEXT AS "Sold Units", 
        (sum(case when carsales.issold = 'True' THEN carsales.price else 0 end))::TEXT AS "Total Sales $",
        TO_CHAR(MAX(carsales.saledate), 'MM-DD-YYYY')::TEXT AS "Last Purchased At"
    FROM carsales
    JOIN make ON carsales.makecode = make.makecode
    JOIN model ON carsales.modelcode = model.modelcode
    GROUP BY make.makename, model.modelname
    ORDER BY make.makename;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS addcarsale(TEXT, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION addcarsale(
    make TEXT,
    model TEXT,
    builtyear TEXT,
    odometer TEXT,
    price TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    makecode_var VARCHAR(5);
    modelcode_var VARCHAR(10);
    trimmed_make TEXT := TRIM(make);
    trimmed_model TEXT := TRIM(model);
BEGIN
    SELECT MakeCode INTO makecode_var
    FROM Make
    WHERE LOWER(MakeName) = LOWER(trimmed_make);

    IF makecode_var IS NULL THEN
        RETURN FALSE;
    END IF;

    SELECT ModelCode INTO modelcode_var
    FROM Model
    WHERE LOWER(ModelName) = LOWER(trimmed_model)
      AND MakeCode = makecode_var;

    IF modelcode_var IS NULL THEN
        RETURN FALSE;
    END IF;

    IF odometer::INTEGER <= 0 THEN
        RETURN FALSE;
    END IF;
    IF price::NUMERIC <= 0 THEN
        RETURN FALSE;
    END IF;
    IF builtyear::INTEGER < 1950 OR builtyear::INTEGER > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RETURN FALSE;
    END IF;

    INSERT INTO CarSales (MakeCode, ModelCode, BuiltYear, Odometer, Price, IsSold)
    VALUES (makecode_var, modelcode_var, builtyear::INTEGER, odometer::INTEGER, price::NUMERIC, FALSE);

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

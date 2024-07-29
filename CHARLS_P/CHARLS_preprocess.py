import pandas as pd



if __name__ == "__main__":
    path = "CHARLS_data_pollutants.csv"
    data = pd.read_csv(path, encoding="utf-8")
    print(data.info())
    data["born_year"] = data.groupby("ID")["born_year"].transform(lambda x : x.fillna(x.mean()))
    data["age"] = data["wave"] - data["born_year"]
    data.to_csv("CHARLS_data_pollutants_born.csv", encoding="utf-8")
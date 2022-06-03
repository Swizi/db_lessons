const MongoClient = require('mongodb').MongoClient;
const ObjectId = require('mongodb').ObjectID;
const uri = "mongodb://localhost:27017";
const dbName = "volgatech";
const client = new MongoClient(uri);

async function execute() {
    try {
        await client.connect();
        const db = client.db(dbName)
        const clients = db.collection('clients')
        const hairdressers = db.collection('hairdressers');
        const services = db.collection('services');
        const barbershops = db.collection('barbershops');
        const completed_works = db.collection('completed_works');

        // 3.1 Отобразить коллекции
        const collections = await db.listCollections().toArray();
        console.log(collections);

        // 3.2 Вставка записей
        // Вставка одной записи insertOne
        await clients.insertOne({ full_name: "Ilya Shulepov", email: "ilya-nagibator@mail.ru", phone_number: "89648672085" });
        // Вставка нескольких записей insertMany
        await clients.insertMany([{ full_name: "Ilya Zolotarev", email: "ilya-nagibator@mail.ru", phone_number: "89648673245" },
        { full_name: "Vadim Shokin", email: "dontreply@mail.ru", phone_number: "89648673245" }]);

        // 3.3 Удаление записей
        // Удаление одной записи по условию deleteOne
        await clients.deleteOne({ full_name: "Ilya Shulepov" });
        // Удаление нескольких записей по условию deleteMany
        await clients.deleteMany({ phone_number: "89648673245" });

        // 3.4 Поиск записей
        // Поиск по ID
        await clients.find({ _id: ObjectId("5d71522dc452f78e335d2d8b") });
        // Поиск записи по атрибуту первого уровня
        await clients.find({ full_name: "Ilya Zolotarev" });
        // Поиск записи по вложенному атрибуту
        await clients.find({ "info.full_name": "Ilya Zolotarev" });
        // Поиск записи по нескольким атрибутам(логический оператор AND)
        await clients.find({ full_name: "Ilya Zolotarev", email: "ilya-nagibator@mail.ru" });
        // Поиск записи по одному из условий(логический оператор OR)
        await clients.find({ $or: [{ full_name: "Yury Uskov" }, { full_name: "Sasha Galochkin" }] });
        // Поиск с использованием оператора сравнения
        await services.find({ price: { $gte: 20 } });
        // Поиск с использованием двух операторов сравнения
        await services.find({ price: { $gte: 20, $lte: 30 }});
        // Поиск по значению в массиве
        await hairdressers.find({ reviews: { $elemMatch: { "text": "Very good! I like it" } } });
        // Поиск по количеству элементов в массиве
        await hairdressers.find({ reviews: { $size: 10 } });
        // Поиск записей без атрибута
        await hairdressers.find();

        // 3.5 Обновление записей
        // Изменить значение атрибута у записи
        await clients.updateOne(
            { full_name: "Ivan Ivanov" },
            {
                $set: { "full_name": "Petr Petrov" },
                $currentDate: { lastModified: true }
            }
        );
        // Удалить атрибут у записи
        await clients.updateMany(
            {},
            { $unset: { full_name: "" } }
        );
        // Добавить атрибут записи
        await clients.updateMany(
            {},
            { $set: { age: "" } }
        );
    } catch (err) {
        console.log(err);
    } finally {
        await client.close();
    }
}
execute();

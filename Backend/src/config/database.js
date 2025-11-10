const sql = require('mssql');

const config = {
    server: process.env.DB_SERVER || 'localhost',
    port: parseInt(process.env.DB_PORT || '1433'),
    user: process.env.DB_USER || 'sa',
    password: process.env.DB_PASSWORD,
    database: 'master',
    options: {
        encrypt: process.env.DB_ENCRYPT === 'true',
        trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true',
        enableArithAbort: true,
        connectionTimeout: 30000,
        requestTimeout: 30000
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
};

const hospitalConfig = {
    ...config,
    database: process.env.DB_DATABASE || process.env.DB_NAME || 'HospitalDB'
};

let pool = null;
let hospitalPool = null;

async function getConnection(retries = 5, useHospitalDB = false) {
    const targetConfig = useHospitalDB ? hospitalConfig : config;
    const targetPool = useHospitalDB ? hospitalPool : pool;

    if (targetPool && targetPool.connected) {
        return targetPool;
    }

    for (let i = 0; i < retries; i++) {
        try {
            console.log(`Intentando conectar a ${targetConfig.database} (${i + 1}/${retries})...`);
            const newPool = await sql.connect(targetConfig);
            
            if (useHospitalDB) {
                hospitalPool = newPool;
            } else {
                pool = newPool;
            }
            
            console.log(`✓ Conectado a ${targetConfig.database}`);
            return newPool;
        } catch (error) {
            console.error(`Error en intento ${i + 1}:`, error.message);
            
            if (i < retries - 1) {
                console.log('Esperando 5 segundos antes de reintentar...');
                await new Promise(resolve => setTimeout(resolve, 5000));
            } else {
                throw new Error(`No se pudo conectar después de ${retries} intentos: ${error.message}`);
            }
        }
    }
}

async function createDatabase() {
    try {
        const masterPool = await getConnection(5, false);
        const dbName = process.env.DB_DATABASE || 'HospitalDB';
        
        console.log(`Verificando base de datos ${dbName}...`);
        
        const result = await masterPool.request()
            .query(`SELECT name FROM sys.databases WHERE name = '${dbName}'`);
        
        if (result.recordset.length === 0) {
            console.log(`Creando base de datos ${dbName}...`);
            await masterPool.request().query(`CREATE DATABASE ${dbName}`);
            console.log(`✓ Base de datos ${dbName} creada`);
        } else {
            console.log(`✓ Base de datos ${dbName} ya existe`);
        }
        
        await masterPool.close();
        pool = null;
        
        return await getConnection(5, true);
        
    } catch (error) {
        console.error('Error creando base de datos:', error.message);
        throw error;
    }
}

async function executeQuery(query, params = {}) {
    try {
        const dbPool = hospitalPool || await getConnection(5, true);
        const request = dbPool.request();

        Object.keys(params).forEach(key => {
            request.input(key, params[key]);
        });

        const result = await request.query(query);
        return result.recordset;
    } catch (error) {
        console.error('Error ejecutando query:', error.message);
        throw error;
    }
}

async function closeConnection() {
    if (pool) {
        await pool.close();
        pool = null;
    }
    if (hospitalPool) {
        await hospitalPool.close();
        hospitalPool = null;
    }
    console.log('✓ Conexiones cerradas');
}

module.exports = {
    getConnection,
    createDatabase,
    executeQuery,
    closeConnection,
    sql
};

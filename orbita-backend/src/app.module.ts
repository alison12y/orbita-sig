import { Module } from '@nestjs/common';
import { TypeOrmModule, TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { UsuariosModule } from './usuarios/usuarios.module';
import { NotificationsModule } from './notifications/notifications.module';
import { User } from './auth/entities/user.entity';
import { Tutor } from './usuarios/entities/tutor.entity';
import { Hijo } from './usuarios/entities/hijo.entity';
import { Notification } from './notifications/entities/notification.entity';
import { ZonasSegurasModule } from './zonas-seguras/zonas-seguras.module';
import { ZonaSegura } from './zonas-seguras/entities/zona-segura.entity';
import { RegistrosModule } from './registros/registros.module';
import { Registro } from './registros/entities/registro.entity';
import { UbicacionModule } from './ubicacion/ubicacion.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => {
        const databaseUrl = configService.get<string>('DATABASE_URL');
        return {
          type: 'postgres',
          ...(databaseUrl
            ? {
                url: databaseUrl,
                ssl: configService.get('NODE_ENV') === 'production' ? { rejectUnauthorized: false } : false,
              }
            : {
                host: configService.get<string>('DB_HOST', 'localhost'),
                port: Number(configService.get<string>('DB_PORT', '5432')),
                username: configService.get<string>('DB_USERNAME', 'postgres'),
                password: configService.get<string>('DB_PASSWORD', '123'),
                database: configService.get<string>('DB_DATABASE') || configService.get<string>('DB_NAME') || 'safesteps',
              }),
          entities: [User, Tutor, Hijo, Notification, ZonaSegura, Registro],
          synchronize: true, // Habilitado para MVP en Render
          logging: configService.get('NODE_ENV') === 'development',
        } as TypeOrmModuleOptions;
      },
      inject: [ConfigService],
    }),
    AuthModule,
    UsuariosModule,
    NotificationsModule,
    ZonasSegurasModule,
    RegistrosModule,
    UbicacionModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

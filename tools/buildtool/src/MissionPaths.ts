import { Preset, FolderStructureInfo } from './Config';
import * as path from "path";

export class MissionPaths {

    static readonly missionSQM = 'mission.Altis.sqm';

    private preset: Preset;

    private folderStructure: FolderStructureInfo;

    private version: string;

    constructor(preset: Preset, folderStructure: FolderStructureInfo, version: string) {
        this.preset = preset;
        this.folderStructure = folderStructure;
        this.version = version;
    }

    public getMap(): string {
        return this.preset.map;
    }

    public getName(): string {
        return this.preset.missionName;
    }

    public getFullName(): string {
        //console.log('getFullName: ');
        //console.log(this.version);
        return [this.getName() + ' ' + this.version, this.getMap()].join('.');
    }

    public getWorkDir(): string {
        return this.folderStructure.workDir;
    }

    /**
     * Get path to source mission.sqm file
     */
    public getMissionSqmPath(): string {
        return path.resolve(
            this.folderStructure.missionsFolder,
            'mission.' + this.preset.map + '.sqm'
        );
    }

    /**
     * Get path to folder with mission framework files.
     */
    public getFrameworkPath(): string {
        return path.resolve(this.folderStructure.frameworkFolder);
    }

    /** 
     * Get path to folder containing mission files 
     */
    public getOutputDir(): string {
        return path.resolve(
            this.folderStructure.workDir,
            this.getFullName()
        );
    }

    /** 
     * Get path to file with mission configuration.
     * As defined in preset.
     */
    public getMissionConfigFilePaths(): string[] {
        var workDir = this.folderStructure.missionsFolder;
        return this.preset.configFiles.map(function (f) {
            return path.resolve(workDir, f);
        });
    }

}
